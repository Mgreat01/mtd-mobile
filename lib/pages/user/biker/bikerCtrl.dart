import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/notification/appNotification.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/composant/courseBiker/BikerHistoryCtrl.dart';
import 'bikerState.dart';

class BikerController extends StateNotifier<BikerState> {
  final BikerService _bikerService = getIt.get<BikerService>();
  final Ref ref;
  StreamSubscription<Position>? _positionSubscription;

  StreamSubscription<ServiceStatus>? _gpsServiceSubscription;

  Timer? _notifTimer;

  List<AppNotification> _oldNotifications = [];

  BikerController(this.ref) : super(BikerState()) {
    _init();
  }

  Future<void> _init() async {
    /// écoute si l'utilisateur active/désactive le GPS
    _listenLocationService();

    /// tente de récupérer la position
    await _initializeLocation();

    await refreshData();

    _startNotificationPolling();
  }

  /// =========================
  /// ECOUTE ACTIVATION GPS
  /// =========================
  void _listenLocationService() {
    _gpsServiceSubscription?.cancel();

    _gpsServiceSubscription =
        Geolocator.getServiceStatusStream().listen(
              (ServiceStatus status) async {
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
          },
        );
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

      final currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      state = state.copyWith(
        currentPosition: currentLatLng,
      );

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

      state = state.copyWith(
        isOnline: false,
      );
    }
  }

  bool get isRaceActive {
    final historyNotifier =
    ref.read(BikerHistoryControllerProvider.notifier);

    return historyNotifier.isRaceActive;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print("GPS désactivé");

      await Geolocator.openLocationSettings();

      return false;
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

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
        ).listen(
              (Position position) async {
            await _sendPositionToServer(position);
          },
        );
  }

  /// =========================
  /// ENVOI POSITION SERVEUR
  /// =========================
  Future<void> _sendPositionToServer(
      Position position,
      ) async {
    final newPosition = LatLng(
      position.latitude,
      position.longitude,
    );

    state = state.copyWith(
      currentPosition: newPosition,
    );

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
    state = state.copyWith(
      isLoading: true,
    );

    try {
      final results = await Future.wait([
        _bikerService.getBalance(),
        _bikerService.getCourses(),
        _bikerService.getPrices(),
      ]);

      final walletBalance = results[0].toString();

      final List<Race> allRaces =
      results[1] as List<Race>;

      final List<dynamic> priceLists =
      results[2] as List<dynamic>;

      final String today =
      DateTime.now().toIso8601String().split('T')[0];

      final finishedToday = allRaces.where(
            (r) =>
        r.status == 'completed' &&
            r.date.toString().contains(today),
      ).toList();

      double dailyTotal = 0.0;

      for (var race in finishedToday) {
        final priceObj = priceLists.firstWhere(
              (p) =>
          p['id'].toString() ==
              race.priceListId.toString(),
          orElse: () => null,
        );

        if (priceObj != null) {
          dailyTotal +=
              double.tryParse(
                priceObj['base_fare'].toString(),
              ) ??
                  0.0;
        }
      }

      state = state.copyWith(
        walletBalance: "$walletBalance CDF",
        races: allRaces,
        completedRacesCount:
        finishedToday
            .where((r) => r.status == 'completed')
            .length,
        dailyRevenue: dailyTotal,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
      );

      print("Erreur BikerController: $e");
    }
  }

  void _startNotificationPolling() {
    _notifTimer?.cancel();

    _notifTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => fetchNotifications(),
    );
  }

  Future<void> fetchNotifications() async {
    try {
      final data =
      await _bikerService.getNotifications();

      final newNotifications = data.where((n) {
        return !_oldNotifications.any(
              (o) => o.id.toString() == n.id.toString(),
        );
      }).toList();

      // update state
      state = state.copyWith(
        notifications: data,
        unreadCount:
        data.where((n) => !n.isRead).length,
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

    super.dispose();
  }
}

final bikerControllerProvider =
StateNotifierProvider.autoDispose<
    BikerController,
    BikerState>(
      (ref) {
    return BikerController(ref);
  },
);