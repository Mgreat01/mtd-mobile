import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/searchResult/searchResult.dart';

class BikerMarkerData {
  final int id;
  final LatLng position;
  final String name;
  final Race? currentRace;


  const BikerMarkerData({
    required this.id,
    required this.position,
    required this.name,
    this.currentRace,
  });
}

enum UserStep {
  searching,
  confirming,
  waitingForBiker,
  inRace,
}

class UserHomeState {
  final LatLng pickupLocation;
  final LatLng mapCenter;

  final LatLng? destinationLocation;

  final String? currentAddress;

  final String? destinationAddress;

  final bool isLoading;

  final List<SearchResult> searchResults;

  final List<BikerMarkerData> nearbyBikers;
  final RaceRouteModel? currentRoute;
  final List<List<double>> routeCoordinates;

  final BikerMarkerData? selectedBiker;

  final Race? currentRace;

  final UserStep step;
  final double? routeDistanceKm;
  final double? routeDurationMin;
  final String? errorMessage;

  const UserHomeState({
    required this.pickupLocation,
    required this.mapCenter,

    this.destinationLocation,

    this.currentAddress,
    this.destinationAddress,

    this.isLoading = false,
    this.searchResults = const [],

    this.nearbyBikers = const [],
    this.selectedBiker,

    this.currentRoute,
    this.routeCoordinates = const [],

    this.currentRace,
    this.step = UserStep.searching,
    this.routeDistanceKm,
    this.routeDurationMin,
    this.errorMessage,
  });

  UserHomeState copyWith({
    LatLng? pickupLocation,
    LatLng? mapCenter,
    LatLng? destinationLocation,

    String? currentAddress,
    String? destinationAddress,

    bool? isLoading,
    List<SearchResult>? searchResults,

    List<BikerMarkerData>? nearbyBikers,
    BikerMarkerData? selectedBiker,
    RaceRouteModel? currentRoute,

    List<List<double>>? routeCoordinates,

    Race? currentRace,
    UserStep? step,
    double? routeDistanceKm,
    double? routeDurationMin,
    String? errorMessage,
  }) {
    return UserHomeState(
      pickupLocation: pickupLocation ?? this.pickupLocation,
      mapCenter: mapCenter ?? this.mapCenter,
      destinationLocation: destinationLocation ?? this.destinationLocation,

      currentAddress: currentAddress ?? this.currentAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,

      isLoading: isLoading ?? this.isLoading,
      searchResults: searchResults ?? this.searchResults,


      nearbyBikers: nearbyBikers ?? this.nearbyBikers,
      selectedBiker: selectedBiker ?? this.selectedBiker,
      currentRoute: currentRoute ?? this.currentRoute,

      routeCoordinates:
      routeCoordinates ?? this.routeCoordinates,

      currentRace: currentRace ?? this.currentRace,
      step: step ?? this.step,
      routeDistanceKm:
      routeDistanceKm ?? this.routeDistanceKm,

      routeDurationMin:
      routeDurationMin ?? this.routeDurationMin,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // UserHomeState clearDestination() {
  //   return copyWith(
  //     destinationLocation: null,
  //     destinationAddress: null,
  //     searchResults: [],
  //   );
  // }
  //
  //
  // UserHomeState clearRace() {
  //   return copyWith(
  //     currentRace: null,
  //     selectedBiker: null,
  //     step: UserStep.searching,
  //   );
  // }
}