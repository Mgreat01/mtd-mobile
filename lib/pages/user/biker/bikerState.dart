import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/notification/appNotification.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';

class BikerState {
  final bool isOnline;
  final LatLng currentPosition;
  final double dailyRevenue;
  final int completedRacesCount;
  final String walletBalance;
  final List<Race> races;
  final bool isLoading;
  final List<AppNotification> notifications;
  final int unreadCount;
  final Race? activeRace;
  final List<List<double>> routeCoordinates;
  final double? routeDistanceKm;
  final double? routeDurationMin;
  final String? routeError;

  BikerState({
    this.isOnline = false,
    this.currentPosition = const LatLng(-4.325, 15.3222),
    this.dailyRevenue = 0.0,
    this.completedRacesCount = 0,
    this.walletBalance = "0 CDF",
    this.races = const [],
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.activeRace,
    this.routeCoordinates = const [],
    this.routeDistanceKm,
    this.routeDurationMin,
    this.routeError,
  });

  BikerState copyWith({
    bool? isOnline,
    LatLng? currentPosition,
    double? dailyRevenue,
    int? completedRacesCount,
    String? walletBalance,
    List<Race>? races,
    bool? isLoading,
    List<AppNotification>? notifications,
    int? unreadCount,
    Race? activeRace,
    bool clearActiveRace = false,
    List<List<double>>? routeCoordinates,
    double? routeDistanceKm,
    double? routeDurationMin,
    String? routeError,
    bool clearRouteError = false,
  }) {
    return BikerState(
      isOnline: isOnline ?? this.isOnline,
      currentPosition: currentPosition ?? this.currentPosition,
      dailyRevenue: dailyRevenue ?? this.dailyRevenue,
      completedRacesCount: completedRacesCount ?? this.completedRacesCount,
      walletBalance: walletBalance ?? this.walletBalance,
      races: races ?? this.races,
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      activeRace: clearActiveRace ? null : activeRace ?? this.activeRace,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      routeDistanceKm: routeDistanceKm ?? this.routeDistanceKm,
      routeDurationMin: routeDurationMin ?? this.routeDurationMin,
      routeError: clearRouteError ? null : routeError ?? this.routeError,
    );
  }
}
