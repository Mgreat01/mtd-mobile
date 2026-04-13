import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/searchResult/searchResult.dart';

class BikerMarkerData {
  final int id;
  final LatLng position;
  final String name;

  BikerMarkerData({required this.id, required this.position, required this.name});
}

enum UserStep { searching, confirming, waitingForBiker, inRace }

class UserHomeState {
  final LatLng myLocation;
  final List<BikerMarkerData> nearbyBikers;
  final BikerMarkerData? selectedBiker;
  final Race? currentRace;
  final UserStep step;
  final bool isLoading;
  final String? currentAddress;
  final String? destinationAddress;
  final List<SearchResult> searchResults;

  UserHomeState({
    required this.myLocation,
    this.nearbyBikers = const [],
    this.selectedBiker,
    this.currentRace,
    this.step = UserStep.searching,
    this.isLoading = false,
    this.currentAddress,
    this.destinationAddress,
    this.searchResults = const [],
  });

  UserHomeState copyWith({
    LatLng? myLocation,
    List<BikerMarkerData>? nearbyBikers,
    BikerMarkerData? selectedBiker,
    Race? currentRace,
    UserStep? step,
    bool? isLoading,
    String? currentAddress,
    String? destinationAddress,
    List<SearchResult>? searchResults,
  }) {
    return UserHomeState(
      myLocation: myLocation ?? this.myLocation,
      nearbyBikers: nearbyBikers ?? this.nearbyBikers,
      selectedBiker: selectedBiker ?? this.selectedBiker,
      currentRace: currentRace ?? this.currentRace,
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,

      currentAddress: currentAddress ?? this.currentAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,

      searchResults: searchResults ?? this.searchResults,
    );
  }
}