import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/searchResult/searchResult.dart';

class BikerMarkerData {
  final int id;
  final LatLng position;
  final String name;

  const BikerMarkerData({
    required this.id,
    required this.position,
    required this.name,
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

  final BikerMarkerData? selectedBiker;

  final Race? currentRace;

  final UserStep step;

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

    this.currentRace,
    this.step = UserStep.searching,
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

    Race? currentRace,
    UserStep? step,
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

      currentRace: currentRace ?? this.currentRace,
      step: step ?? this.step,
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