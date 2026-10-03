import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/searchResult/searchResult.dart';

import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';

import 'package:moto_taxi_digital_mobile/framework/race/raceServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/biker/bikerServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/userNetworkServiceImpl.dart';

import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';
import 'package:moto_taxi_digital_mobile/framework/notification/realtimeNotificationService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';

class UserHomeController extends StateNotifier<UserHomeState> {
  final RaceService _raceService;
  final BikerService _bikerService;
  final UserNetworkServiceImpl _networkService;

  Timer? _refreshTimer;
  Timer? _searchDebounce;
  Timer? _mapDebounce;
  bool _syncingRace = false;
  int? _dismissedAcceptanceRaceId;
  int _idleRefreshTick = 0;

  StreamSubscription<ServiceStatus>? _gpsServiceSubscription;
  StreamSubscription<Map<String, dynamic>>? _realtimeSubscription;

  UserHomeController(
    this._raceService,
    this._bikerService,
    this._networkService, {
    bool initialize = true,
  }) : super(
         UserHomeState(
           pickupLocation: const LatLng(-4.322447, 15.307045),
           mapCenter: const LatLng(-4.322447, 15.307045),
         ),
       ) {
    if (initialize) _init();
  }

  Future<void> _init() async {
    // Le GPS et le WebSocket ne doivent pas bloquer la reprise de la course.
    _listenToRealtimeEvents();
    _startRefreshTimer();
    unawaited(_syncActiveRace());

    _listenToGpsChanges();

    await _loadLastKnownLocation();

    await _getUserCurrentLocation();

    // await refreshBikers();
  }

  void _listenToRealtimeEvents() {
    final realtime = getIt.get<RealtimeNotificationService>();
    _realtimeSubscription = realtime.notifications.listen((payload) async {
      switch (payload['_event']) {
        case 'realtime.bootstrap':
          _restoreRealtimeSession(payload);
          return;
        case 'biker.location.updated':
          _applyBikerLocation(payload);
          return;
        case 'race.state.updated':
          await _applyRaceState(payload);
          return;
        case 'race.accepted':
          break;
        default:
          return;
      }

      final race = payload['race'];
      if (race is! Map) {
        debugPrint('Acceptation temps réel ignorée : course absente.');
        return;
      }

      try {
        final acceptedRace = Race.fromJson(Map<String, dynamic>.from(race));
        // Le canal privé garantit que la course appartient au passager. Cette
        // mise à jour couvre le cas où l'application a été rouverte sans état.
        _applySyncedRace(acceptedRace, acceptancePayload: payload);
        _applyBikerLocation(payload);
      } catch (error) {
        debugPrint('Acceptation temps réel invalide : $error');
      }
    });
    unawaited(realtime.connect());
  }

  void _restoreRealtimeSession(Map<String, dynamic> payload) {
    final raceJson = payload['active_race'];
    if (raceJson is! Map) return;
    try {
      final race = Race.fromJson(Map<String, dynamic>.from(raceJson));
      _applySyncedRace(race);
      _applyBikerLocation({
        'race_id': race.id,
        'biker_id': race.bikerId,
        'location': payload['biker_location'],
      });
    } catch (error) {
      debugPrint('Bootstrap de course invalide: $error');
    }
  }

  Future<void> _applyRaceState(Map<String, dynamic> payload) async {
    final raceId = int.tryParse(payload['race_id']?.toString() ?? '');
    if (raceId == null || state.currentRace?.id != raceId) return;

    final status = payload['status']?.toString();
    if (status == 'completed' || status == 'cancelled') {
      state = state.copyWith(
        clearCurrentRace: true,
        clearCurrentRoute: true,
        clearBikerAcceptance: true,
        clearSelectedBiker: true,
        routeCoordinates: const [],
        routeDistanceKm: 0,
        routeDurationMin: 0,
        step: UserStep.searching,
      );
      return;
    }

    try {
      final updatedRace = await _raceService.getRaceById(raceId);
      if (state.currentRace?.id != raceId) return;
      _applySyncedRace(updatedRace);
    } catch (error) {
      debugPrint('Synchronisation etat course impossible: $error');
    }
  }

  void _applySyncedRace(Race race, {Map<String, dynamic>? acceptancePayload}) {
    if (!mounted) return;
    final current = state.currentRace;
    if (current != null && current.id != race.id) return;
    if (race.status == 'completed' || race.status == 'cancelled') {
      state = state.copyWith(
        clearCurrentRace: true,
        clearCurrentRoute: true,
        clearBikerAcceptance: true,
        clearSelectedBiker: true,
        routeCoordinates: const [],
        routeDistanceKm: 0,
        routeDurationMin: 0,
        step: UserStep.searching,
      );
      return;
    }
    if (current?.status == 'ongoing' && race.status == 'pending') return;

    final needsConfirmation = race.status == 'pending' && race.bikerId != null;
    final shouldPrompt =
        needsConfirmation &&
        _dismissedAcceptanceRaceId != race.id &&
        state.bikerAcceptance == null;
    state = state.copyWith(
      currentRace: race,
      step: race.status == 'ongoing'
          ? UserStep.inRace
          : UserStep.waitingForBiker,
      bikerAcceptance: shouldPrompt
          ? acceptancePayload ??
                {
                  'race_id': race.id,
                  'message':
                      'Un biker a accepté votre course. Confirmez-vous le départ ?',
                }
          : null,
      clearBikerAcceptance: !needsConfirmation,
    );
  }

  Future<void> _syncActiveRace() async {
    if (_syncingRace || !mounted || state.isLoading) return;
    _syncingRace = true;
    final initialRaceId = state.currentRace?.id;
    try {
      Race? race;
      if (initialRaceId != null) {
        race = await _raceService
            .getRaceById(initialRaceId)
            .timeout(const Duration(seconds: 8));
      } else {
        final races = await _raceService.showForCurrentUser().timeout(
          const Duration(seconds: 8),
        );
        race = null;
        for (final candidate in races) {
          if (candidate.status == 'pending' ||
              candidate.status == 'accepted' ||
              candidate.status == 'ongoing') {
            race = candidate;
            break;
          }
        }
      }
      if (!mounted || state.currentRace?.id != initialRaceId || race == null) {
        return;
      }
      if (race.status == 'completed' || race.status == 'cancelled') {
        state = state.copyWith(
          clearCurrentRace: true,
          clearCurrentRoute: true,
          clearBikerAcceptance: true,
          clearSelectedBiker: true,
          routeCoordinates: const [],
          step: UserStep.searching,
        );
      } else {
        _applySyncedRace(race);
        if (race.status == 'ongoing' && state.routeCoordinates.isEmpty) {
          unawaited(_loadRaceRoute(race.id, expectedStatus: 'ongoing'));
        }
      }
    } catch (error) {
      debugPrint('Synchronisation de la course passager impossible: $error');
    } finally {
      _syncingRace = false;
    }
  }

  void _applyBikerLocation(Map<String, dynamic> payload) {
    final location = payload['location'] ?? payload['biker_location'];
    if (location is! Map) return;
    final latitude = double.tryParse(location['latitude']?.toString() ?? '');
    final longitude = double.tryParse(location['longitude']?.toString() ?? '');
    final bikerId =
        int.tryParse(payload['biker_id']?.toString() ?? '') ??
        state.currentRace?.bikerId;
    if (latitude == null || longitude == null || bikerId == null) return;

    final raceId = int.tryParse(payload['race_id']?.toString() ?? '');
    if (raceId != null && state.currentRace?.id != raceId) return;

    final previous = state.selectedBiker;
    final marker = BikerMarkerData(
      id: bikerId,
      name: previous?.name ?? 'Biker',
      position: LatLng(latitude, longitude),
      currentRace: state.currentRace,
    );
    final nearby = [
      for (final biker in state.nearbyBikers)
        if (biker.id == bikerId) marker else biker,
      if (!state.nearbyBikers.any((biker) => biker.id == bikerId)) marker,
    ];
    state = state.copyWith(selectedBiker: marker, nearbyBikers: nearby);
  }

  void _listenToGpsChanges() {
    _gpsServiceSubscription?.cancel();

    _gpsServiceSubscription = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) async {
      print("GPS STATUS => $status");

      if (status == ServiceStatus.enabled) {
        print("GPS activé");

        await _getUserCurrentLocation();
      }
    });
  }

  Future<void> _loadLastKnownLocation() async {
    try {
      Position? lastKnown = await Geolocator.getLastKnownPosition();

      if (lastKnown != null) {
        final currentLatLng = LatLng(lastKnown.latitude, lastKnown.longitude);

        state = state.copyWith(
          pickupLocation: currentLatLng,
          mapCenter: currentLatLng,
        );

        print(
          "LAST KNOWN POSITION => "
          "${lastKnown.latitude}, ${lastKnown.longitude}",
        );

        await updateCurrentAddress();
      }
    } catch (e) {
      print("Erreur LastKnownPosition : $e");
    }
  }

  Future<void> _getUserCurrentLocation() async {
    bool hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,

        timeLimit: const Duration(seconds: 10),
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      print(
        "GPS POSITION => "
        "${position.latitude}, ${position.longitude}",
      );

      state = state.copyWith(
        pickupLocation: currentLatLng,
        mapCenter: currentLatLng,
      );
      await updateCurrentAddress();
    } catch (e) {
      print("Erreur GPS : $e");
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print("Le service de localisation est désactivé");

      await Geolocator.openLocationSettings();

      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print("Permission localisation refusée");
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

  void _startRefreshTimer() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (state.currentRace != null || ++_idleRefreshTick % 4 == 0) {
        unawaited(_syncActiveRace());
      }
      if (state.currentRace == null) unawaited(refreshBikers());
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchDebounce?.cancel();
    _mapDebounce?.cancel();

    _gpsServiceSubscription?.cancel();
    _realtimeSubscription?.cancel();

    super.dispose();
  }

  Future<void> refreshBikers() async {
    try {
      final bikers = await _bikerService.getActiveBikers();

      state = state.copyWith(nearbyBikers: bikers);
    } catch (e) {
      print("Erreur refreshBikers: $e");
    }
  }

  Future<void> updateCurrentAddress() async {
    try {
      final address = await _networkService.getAddressFromLatLng(
        state.pickupLocation.latitude,
        state.pickupLocation.longitude,
      );

      state = state.copyWith(currentAddress: address);
    } catch (e) {
      print("Erreur adresse départ: $e");
    }
  }

  void selectBiker(BikerMarkerData biker) {
    state = state.copyWith(selectedBiker: biker);
  }

  void updateLocationFromMap(LatLng newCenter) {
    state = state.copyWith(destinationLocation: newCenter);

    _mapDebounce?.cancel();

    _mapDebounce = Timer(const Duration(milliseconds: 700), () async {
      try {
        final address = await _networkService.getAddressFromLatLng(
          newCenter.latitude,
          newCenter.longitude,
        );

        state = state.copyWith(
          destinationAddress: address,
          destinationLocation: newCenter,
        );
      } catch (e) {
        print("Erreur map destination: $e");
      }
    });
  }

  Future<void> searchAddresses(String query) async {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().length < 3) {
        state = state.copyWith(searchResults: []);

        return;
      }

      try {
        final results = await _networkService.searchAddresses(
          query,

          userLocation: state.pickupLocation,
        );

        state = state.copyWith(searchResults: results);
      } catch (e) {
        print("Erreur recherche: $e");
      }
    });
  }

  void selectSearchResult(SearchResult result) {
    state = state.copyWith(
      mapCenter: result.location,
      destinationLocation: result.location,
      destinationAddress: result.displayName,
      searchResults: [],
    );
  }

  void clearDestination() {
    state = state.copyWith(
      destinationLocation: null,
      destinationAddress: null,
      searchResults: [],
    );
  }

  Future<bool> confirmBooking({
    required String destinationName,
    required int priceListId,
  }) async {
    if (state.isLoading ||
        state.currentRace != null ||
        state.destinationLocation == null ||
        state.destinationAddress == null) {
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final newRace = Race(
        id: 0,
        name: "Course vers $destinationName",
        date: DateTime.now().toIso8601String(),

        startingPoint:
            state.currentAddress ??
            "${state.pickupLocation.latitude},"
                "${state.pickupLocation.longitude}",

        destination: destinationName,

        startLat: state.pickupLocation.latitude,
        startLng: state.pickupLocation.longitude,

        endLat: state.destinationLocation!.latitude,
        endLng: state.destinationLocation!.longitude,

        status: 'pending',
        bikerId: null,
        clientId: 0,
        priceListId: priceListId,

        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdRace = await _raceService.createRace(newRace);
      state = state.copyWith(
        currentRace: createdRace,
        step: UserStep.waitingForBiker,
        isLoading: false,
        clearErrorMessage: true,
      );
      unawaited(_loadRaceRoute(createdRace.id, expectedStatus: 'pending'));
      unawaited(_syncActiveRace());
      return true;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      print("Erreur confirmBooking: $e");
      return false;
    }
  }

  Future<void> _loadRaceRoute(
    int raceId, {
    required String expectedStatus,
  }) async {
    try {
      final route = await _raceService.getRaceRoute(raceId);
      if (mounted &&
          state.currentRace?.id == raceId &&
          state.currentRace?.status == expectedStatus) {
        state = state.copyWith(
          currentRoute: route,
          routeCoordinates: route.route.geometry.coordinates,
          routeDistanceKm: route.route.distance / 1000,
          routeDurationMin: route.route.duration / 60,
        );
      }
    } catch (error) {
      debugPrint('Course créée, itinéraire indisponible: $error');
    }
  }

  Future<bool> cancelRace() async {
    final race = state.currentRace;
    if (race == null || race.status != 'pending' || state.isLoading) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _raceService.deletedRace(race.id);

      if (!mounted) return true;

      state = state.copyWith(
        clearCurrentRace: true,
        clearCurrentRoute: true,
        clearBikerAcceptance: true,
        routeCoordinates: const [],
        routeDistanceKm: 0,
        routeDurationMin: 0,
        clearSelectedBiker: true,
        step: UserStep.searching,
        isLoading: false,
        clearErrorMessage: true,
      );
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        );
      }
      return false;
    }
  }

  Future<void> confirmAcceptedBiker() async {
    final race = state.currentRace;
    if (race == null ||
        race.status != 'pending' ||
        race.bikerId == null ||
        state.isLoading) {
      return;
    }
    state = state.copyWith(
      isLoading: true,
      clearBikerAcceptance: true,
      clearErrorMessage: true,
    );
    try {
      final route = await _raceService.confirmPassenger(race.id);
      if (!mounted || state.currentRace?.id != race.id) return;
      // Une confirmation HTTP réussie suffit : la relecture de la course ne
      // doit pas faire croire au passager que la confirmation a échoué.
      final ongoingRace = Race.fromJson({
        ...race.toJson(),
        'status': 'ongoing',
      });
      state = state.copyWith(
        currentRace: ongoingRace,
        currentRoute: route,
        routeCoordinates: route.route.geometry.coordinates,
        routeDistanceKm: route.route.distance / 1000,
        routeDurationMin: route.route.duration / 60,
        step: UserStep.inRace,
        isLoading: false,
        clearErrorMessage: true,
      );
      unawaited(_syncActiveRace());
    } catch (error) {
      if (!mounted || state.currentRace?.id != race.id) return;
      // Le serveur peut avoir démarré la course avant qu'une réponse ou une
      // route valide nous parvienne. Vérifier l'état avant de proposer un retry.
      try {
        final latest = await _raceService.getRaceById(race.id);
        if (!mounted || state.currentRace?.id != race.id) return;
        if (latest.status == 'ongoing') {
          state = state.copyWith(
            currentRace: latest,
            step: UserStep.inRace,
            isLoading: false,
            clearErrorMessage: true,
          );
          unawaited(_loadRaceRoute(race.id, expectedStatus: 'ongoing'));
          return;
        }
      } catch (syncError) {
        debugPrint('Vérification de confirmation impossible: $syncError');
      }
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> completeActiveRace() async {
    final race = state.currentRace;
    if (race == null || race.status != 'ongoing' || state.isLoading) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _raceService.completeRace(race.id);
      if (!mounted || state.currentRace?.id != race.id) return true;
      state = state.copyWith(
        clearCurrentRace: true,
        clearCurrentRoute: true,
        clearBikerAcceptance: true,
        routeCoordinates: const [],
        routeDistanceKm: 0,
        routeDurationMin: 0,
        clearSelectedBiker: true,
        step: UserStep.searching,
        isLoading: false,
        clearErrorMessage: true,
      );
      await refreshBikers();
      return true;
    } catch (error) {
      try {
        final latest = await _raceService.getRaceById(race.id);
        if (!mounted || state.currentRace?.id != race.id) return true;
        if (latest.status == 'completed') {
          state = state.copyWith(
            clearCurrentRace: true,
            clearCurrentRoute: true,
            clearBikerAcceptance: true,
            clearSelectedBiker: true,
            routeCoordinates: const [],
            routeDistanceKm: 0,
            routeDurationMin: 0,
            step: UserStep.searching,
            isLoading: false,
            clearErrorMessage: true,
          );
          return true;
        }
      } catch (syncError) {
        debugPrint('Vérification de fin de course impossible: $syncError');
      }
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void dismissBikerAcceptance() {
    _dismissedAcceptanceRaceId = state.currentRace?.id;
    state = state.copyWith(clearBikerAcceptance: true);
  }

  void showBikerAcceptance() {
    final race = state.currentRace;
    if (race == null || race.status != 'pending' || race.bikerId == null) {
      return;
    }
    _dismissedAcceptanceRaceId = null;
    state = state.copyWith(
      bikerAcceptance: {
        'race_id': race.id,
        'message':
            'Un biker a accepté votre course. Confirmez-vous le départ ?',
      },
    );
  }

  // Future<void> previewRoute() async {
  //
  //   if(state.destinationLocation == null) return;
  //
  //   final route =
  //   await _raceService.getRaceRoute(
  //
  //     startLat: state.pickupLocation.latitude,
  //     startLng: state.pickupLocation.longitude,
  //
  //     endLat: state.destinationLocation!.latitude,
  //     endLng: state.destinationLocation!.longitude,
  //   );
  //
  //   state = state.copyWith(
  //
  //     routeCoordinates:
  //     route.route.geometry.coordinates,
  //
  //     routeDistanceKm:
  //     route.route.distance / 1000,
  //
  //     routeDurationMin:
  //     route.route.duration / 60,
  //   );
  // }
}

final userHomeControllerProvider =
    StateNotifierProvider.autoDispose<UserHomeController, UserHomeState>(
      (ref) => UserHomeController(
        RaceServiceImpl(),
        BikerServiceImpl(),
        UserNetworkServiceImpl(),
      ),
    );
