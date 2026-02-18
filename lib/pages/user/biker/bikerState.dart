import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';

class BikerState {
  final bool isOnline;
  final LatLng currentPosition;
  final double dailyRevenue;
  final int completedRacesCount;
  final String walletBalance;
  final List<Race> races;
  final bool isLoading;

  BikerState({
    this.isOnline = false,
    this.currentPosition = const LatLng(-4.325, 15.3222),
    this.dailyRevenue = 0.0,
    this.completedRacesCount = 0,
    this.walletBalance = "0 CDF",
    this.races = const [],
    this.isLoading = false,
  });

  BikerState copyWith({
    bool? isOnline,
    LatLng? currentPosition,
    double? dailyRevenue,
    int? completedRacesCount,
    String? walletBalance,
    List<Race>? races,
    bool? isLoading,
  }) {
    return BikerState(
      isOnline: isOnline ?? this.isOnline,
      currentPosition: currentPosition ?? this.currentPosition,
      dailyRevenue: dailyRevenue ?? this.dailyRevenue,
      completedRacesCount: completedRacesCount ?? this.completedRacesCount,
      walletBalance: walletBalance ?? this.walletBalance,
      races: races ?? this.races,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}