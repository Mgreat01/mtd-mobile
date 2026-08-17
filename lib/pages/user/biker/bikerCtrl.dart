import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/notification/appNotification.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/framework/notification/realtimeNotificationService.dart';
import 'bikerState.dart';

class BikerController extends StateNotifier<BikerState> {
  final BikerService _bikerService = getIt.get<BikerService>();
  final Ref ref;
  StreamSubscription<Position>? _positionSubscription;

  StreamSubscription<ServiceStatus>? _gpsServiceSubscription;

  Timer? _notifTimer;
  StreamSubscription<Map<String, dynamic>>? _realtimeNotificationSubscription;
  DateTime? _lastRouteRefreshAt;
  LatLng? _lastRouteRefreshPosition;
  Future<void>? _routeLoadInProgress;

  List<AppNotification> _oldNotifications = [];

  BikerController(this.ref) : super(BikerState()) {
    _init();
  }

  Future<void> _init() async {
    /// écoute si l'utilisateur active/désactive le GPS
    _listenLocationService();

    // Les notifications ne doivent pas attendre le GPS ni les autres appels
    // du tableau de bord pour apparaître.
    await fetchNotifications();
    await _initializeRealtimeNotifications();
    _startNotificationPolling();

    /// tente de récupérer la position
    await _initializeLocation();

    await refreshData();
  }

  /// =========================
  /// ECOUTE ACTIVATION GPS
  /// =========================
  void _listenLocationService() {
    _gpsServiceSubscription?.cancel();

    _gpsServiceSubscription = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) async {
      print("Etat GPS : $status");

      /// si le GPS vient d'être activé
      if (status == ServiceStatus.enabled) {
        await _initializeLocation();

        /// si le biker est online
        if (state.isOnline) {
          _startLocationTracking();
        }
      }

      /// si GPS coupé
      if (status == ServiceStatus.disabled) {
        print("GPS désactivé");

        _positionSubscription?.cancel();
      }
    });
  }

  /// =========================
  /// INITIALISATION POSITION
  /// =========================
  Future<void> _initializeLocation() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) {
      print("Permission GPS refusée");
      return;
    }

    try {
      Position position;

      /// tente d'abord dernière position connue
      final lastPosition = await Geolocator.getLastKnownPosition();

      if (lastPosition != null) {
        position = lastPosition;
      } else {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 15),
        );
      }

      final currentLatLng = LatLng(position.latitude, position.longitude);

      state = state.copyWith(currentPosition: currentLatLng);

      print(
        "Position biker : "
        "${position.latitude}, ${position.longitude}",
      );
    } catch (e) {
      print("Erreur récupération position biker : $e");
    }
  }

  /// =========================
  /// START / STOP SERVICE
  /// =========================
  Future<void> toggleService() async {
    if (!state.isOnline) {
      bool hasPermission = await _handleLocationPermission();
      if (hasPermission) {
        state = state.copyWith(isOnline: true);
        _startLocationTracking();
      }
    } else {
      _stopLocationTracking();

      state = state.copyWith(isOnline: false);
    }
  }

  bool get isRaceActive {
    return state.activeRace != null ||
        state.races.any(_isAssignedActiveRace);
  }

  bool _isAssignedActiveRace(Race race) {
    return race.status == 'ongoing' ||
        (race.status == 'pending' && race.bikerId != null);
  }

  Future<void> applyRaceUpdate(Race race) async {
    final races = [
      for (final existing in state.races)
        if (existing.id == race.id) race else existing,
      if (!state.races.any((existing) => existing.id == race.id)) race,
    ];

    state = state.copyWith(races: races);
    if (_isAssignedActiveRace(race)) {
      state = state.copyWith(activeRace: race);
      await _loadRouteToPassenger(race, waitForCurrent: true);
    } else if (state.activeRace?.id == race.id) {
      _clearActiveRoute();
    }
  }

  Future<void> _loadRouteToPassenger(
    Race race, {
    bool waitForCurrent = false,
  }) async {
    final currentLoad = _routeLoadInProgress;
    if (currentLoad != null) {
      if (!waitForCurrent) return;
      await currentLoad;
    }

    final routeLoad = _performRouteLoad(race);
    _routeLoadInProgress = routeLoad;
    try {
      await routeLoad;
    } finally {
      if (identical(_routeLoadInProgress, routeLoad)) {
        _routeLoadInProgress = null;
      }
    }
  }

  Future<void> _performRouteLoad(Race race) async {
    state = state.copyWith(clearRouteError: true, isRouteLoading: true);
    try {
      final route = await _bikerService.getBikerPassengerTrack(
        raceId: race.id,
        lat: state.currentPosition.latitude,
        lng: state.currentPosition.longitude,
      );

      if (route == null || route.route.geometry.coordinates.length < 2) {
        throw Exception("Aucun itinéraire reçu du serveur");
      }

      state = state.copyWith(
        activeRace: race,
        routeCoordinates: route.route.geometry.coordinates,
        routeDistanceKm: route.route.distance / 1000,
        routeDurationMin: route.route.duration / 60,
        clearRouteError: true,
        isRouteLoading: false,
      );
      _lastRouteRefreshAt = DateTime.now();
      _lastRouteRefreshPosition = state.currentPosition;
    } catch (e) {
      state = state.copyWith(
        activeRace: race,
        routeError: "Impossible de charger l'itinéraire : $e",
        isRouteLoading: false,
      );
    }
  }

  void _refreshActiveRouteIfNeeded(LatLng position) {
    final race = state.activeRace;
    if (race == null || _routeLoadInProgress != null) return;

    final lastPosition = _lastRouteRefreshPosition;
    final lastRefresh = _lastRouteRefreshAt;
    final movedMeters = lastPosition == null
        ? double.infinity
        : Geolocator.distanceBetween(
            lastPosition.latitude,
            lastPosition.longitude,
            position.latitude,
            position.longitude,
          );
    final elapsed = lastRefresh == null
        ? const Duration(days: 1)
        : DateTime.now().difference(lastRefresh);

    // Recalculer seulement après un mouvement significatif. La limite de temps
    // évite une rafale de requêtes Mapbox lorsque le GPS oscille sur place.
    if (movedMeters >= 25 && elapsed >= const Duration(seconds: 15)) {
      unawaited(_loadRouteToPassenger(race));
    }
  }

  void _clearActiveRoute() {
    state = state.copyWith(
      clearActiveRace: true,
      routeCoordinates: const [],
      routeDistanceKm: 0,
      routeDurationMin: 0,
      clearRouteError: true,
      isRouteLoading: false,
    );
    _lastRouteRefreshAt = null;
    _lastRouteRefreshPosition = null;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print("GPS désactivé");

      await Geolocator.openLocationSettings();

      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print("Permission refusée");

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permission refusée définitivement");

      await Geolocator.openAppSettings();

      return false;
    }
    return true;
  }

  void _startLocationTracking() async {
    _positionSubscription?.cancel();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      await _sendPositionToServer(position);
    } catch (e) {
      print("Erreur position initiale : $e");
    }

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((Position position) async {
          await _sendPositionToServer(position);
        });
  }

  /// =========================
  /// ENVOI POSITION SERVEUR
  /// =========================
  Future<void> _sendPositionToServer(Position position) async {
    final newPosition = LatLng(position.latitude, position.longitude);

    state = state.copyWith(currentPosition: newPosition);
    _refreshActiveRouteIfNeeded(newPosition);

    print(
      "Nouvelle position : "
      "${position.latitude}, ${position.longitude}",
    );

    if (state.isOnline) {
      try {
        await _bikerService.updateLocation(
          lat: position.latitude,
          lng: position.longitude,
          isActive: true,
        );
      } catch (e) {
        print("Erreur update location : $e");
      }
    }
  }

  /// =========================
  /// STOP TRACKING
  /// =========================
  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    _bikerService.updateLocation(
      lat: state.currentPosition.latitude,
      lng: state.currentPosition.longitude,
      isActive: false,
    );
  }

  /// =========================
  /// REFRESH DATA
  /// =========================
  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await Future.wait([
        _bikerService.getBalance(),
        _bikerService.getCourses(),
        _bikerService.getBikerRaces(),
        _bikerService.getPrices(),
      ]);

      final walletBalance = results[0].toString();

      final availableRaces = results[1] as List<Race>;
      final bikerRaces = results[2] as List<Race>;
      final racesById = <int, Race>{
        for (final race in availableRaces) race.id: race,
        for (final race in bikerRaces) race.id: race,
      };
      final allRaces = racesById.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final List<dynamic> priceLists = results[3] as List<dynamic>;

      final String today = DateTime.now().toIso8601String().split('T')[0];

      final finishedToday = allRaces
          .where(
            (r) => r.status == 'completed' && r.date.toString().contains(today),
          )
          .toList();

      double dailyTotal = 0.0;

      for (var race in finishedToday) {
        final priceObj = priceLists.firstWhere(
          (p) => p['id'].toString() == race.priceListId.toString(),
          orElse: () => null,
        );

        if (priceObj != null) {
          dailyTotal +=
              double.tryParse(priceObj['base_fare'].toString()) ?? 0.0;
        }
      }

      state = state.copyWith(
        walletBalance: "$walletBalance CDF",
        races: allRaces,
        completedRacesCount: finishedToday
            .where((r) => r.status == 'completed')
            .length,
        dailyRevenue: dailyTotal,
        isLoading: false,
      );

      final activeRace = allRaces
          .where(_isAssignedActiveRace)
          .firstOrNull;
      if (activeRace != null) {
        state = state.copyWith(activeRace: activeRace);
        await _loadRouteToPassenger(activeRace);
      } else if (state.activeRace != null) {
        _clearActiveRoute();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);

      print("Erreur BikerController: $e");
    }
  }

  void _startNotificationPolling() {
    _notifTimer?.cancel();

    _notifTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => fetchNotifications(),
    );
  }

  Future<void> _initializeRealtimeNotifications() async {
    final realtimeService = getIt.get<RealtimeNotificationService>();
    _realtimeNotificationSubscription = realtimeService.notifications.listen((payload) {
      _applyRealtimeNotification(payload);
      unawaited(fetchNotifications());
      unawaited(refreshData());
    });
    await realtimeService.connect();
  }

  void _applyRealtimeNotification(Map<String, dynamic> payload) {
    final id = int.tryParse(payload['id']?.toString() ?? '');
    if (id == null || state.notifications.any((item) => item.id == id)) return;

    final notification = AppNotification(
      id: id,
      title: payload['title']?.toString() ?? 'Nouvelle notification',
      message: payload['message']?.toString() ?? '',
      assignedAt: payload['created_at']?.toString(),
    );
    final notifications = [notification, ...state.notifications];
    _oldNotifications = notifications;
    state = state.copyWith(
      notifications: notifications,
      unreadCount: state.unreadCount + 1,
    );
  }

  Future<void> fetchNotifications() async {
    try {
      final data = await _bikerService.getNotifications();

      final newNotifications = data.where((n) {
        return !_oldNotifications.any(
          (o) => o.id.toString() == n.id.toString(),
        );
      }).toList();

      // update state
      state = state.copyWith(
        notifications: data,
        unreadCount: data.where((n) => !n.isRead).length,
      );

      if (newNotifications.isNotEmpty) {
        print(
          "Nouvelles notifications : "
          "${newNotifications.length}",
        );
      }

      _oldNotifications = data;
    } catch (e) {
      print("notif error: $e");
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();

    _gpsServiceSubscription?.cancel();

    _notifTimer?.cancel();
    _realtimeNotificationSubscription?.cancel();

    super.dispose();
  }
}

final bikerControllerProvider=
    StateNotifierProvider.autoDispose<BikerController, BikerState>((ref) {
      return BikerController(ref);
    });
