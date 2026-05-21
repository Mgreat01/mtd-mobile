import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'; // Ajouté pour le GPS
import 'package:latlong2/latlong.dart';

import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/searchResult/searchResult.dart';

import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';

import 'package:moto_taxi_digital_mobile/framework/race/raceServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/biker/bikerServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/userNetworkServiceImpl.dart';

import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';

class UserHomeController extends StateNotifier<UserHomeState> {
  final RaceService _raceService;
  final BikerService _bikerService;
  final UserNetworkServiceImpl _networkService;

  Timer? _refreshTimer;
  Timer? _searchDebounce;
  Timer? _mapDebounce;

  UserHomeController(
      this._raceService,
      this._bikerService,
      this._networkService,
      ) : super(
    UserHomeState(
      pickupLocation: const LatLng(-4.322447, 15.307045),
      mapCenter: const LatLng(-4.322447, 15.307045),
    ),
  ) {
    _init();
  }

  Future<void> _init() async {
    await _getUserCurrentLocation();
    await refreshBikers();
    _startRefreshTimer();
  }


  Future<void> _getUserCurrentLocation() async {

    bool hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;

    try {

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      print("GPS POSITION : "
          "${position.latitude}, ${position.longitude}");

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

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
          (_) => refreshBikers(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchDebounce?.cancel();
    _mapDebounce?.cancel();
    super.dispose();
  }

  Future<void> refreshBikers() async {
    try {
      final bikers = await _bikerService.getActiveBikers();

      state = state.copyWith(
        nearbyBikers: bikers,
      );
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

      state = state.copyWith(
        currentAddress: address,
      );
    } catch (e) {
      print("Erreur adresse départ: $e");
    }
  }

  void selectBiker(BikerMarkerData biker) {
    state = state.copyWith(
      selectedBiker: biker,
    );
  }

  void updateLocationFromMap(LatLng newCenter) {
    state = state.copyWith(
      destinationLocation: newCenter,
    );

    _mapDebounce?.cancel();

    _mapDebounce = Timer(
      const Duration(milliseconds: 700),
          () async {
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
      },
    );
  }

  Future<void> searchAddresses(String query) async {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
          () async {
        if (query.trim().length < 3) {
          state = state.copyWith(searchResults: []);
          return;
        }

        try {
          final results = await _networkService.searchAddresses(query);

          state = state.copyWith(
            searchResults: results,
          );
        } catch (e) {
          print("Erreur recherche: $e");
        }
      },
    );
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

  Future<void> confirmBooking({
    required String destinationName,
    required int priceListId,
  }) async {
    if (state.destinationLocation == null ||
        state.destinationAddress == null) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final newRace = Race(
        id: 0,
        name: "Course vers $destinationName",
        date: DateTime.now().toIso8601String(),

        startingPoint: state.currentAddress ??
            "${state.pickupLocation.latitude},${state.pickupLocation.longitude}",

        destination: destinationName,

        startLat: state.pickupLocation.latitude,
        startLng: state.pickupLocation.longitude,

        endLat: state.destinationLocation!.latitude,
        endLng: state.destinationLocation!.longitude,

        status: 'pending',
        bikerId: 0,
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
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Erreur confirmBooking: $e");
    }
  }

  Future<void> cancelRace() async {
    if (state.currentRace == null) return;

    try {
      await _raceService.deletedRace(state.currentRace!.id);

      state = state.copyWith(
        currentRace: null,
        selectedBiker: null,
        step: UserStep.searching,
      );
    } catch (e) {
      print("Erreur annulation: $e");
    }
  }
}

final userHomeControllerProvider =
StateNotifierProvider.autoDispose<UserHomeController, UserHomeState>(
      (ref) => UserHomeController(
    RaceServiceImpl(),
    BikerServiceImpl(),
    UserNetworkServiceImpl(),
  ),
);