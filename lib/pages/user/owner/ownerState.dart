import 'package:moto_taxi_digital_mobile/business/models/bike/bike.dart';

class OwnerState {
  final List<Bike> bikes;
  final Map<String, dynamic> stats;
  final bool isLoading;
  final String? errorMessage;

  OwnerState({
    this.bikes = const [],
    this.stats = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  OwnerState copyWith({
    List<Bike>? bikes,
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OwnerState(
      bikes: bikes ?? this.bikes,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
