import 'package:moto_taxi_digital_mobile/business/models/bike/bike.dart';

class OwnerState {
  final List<Bike> bikes;
  final Map<String, dynamic> stats;
  final bool isLoading;

  OwnerState({this.bikes = const [], this.stats = const {}, this.isLoading = false});

  OwnerState copyWith({List<Bike>? bikes, Map<String, dynamic>? stats, bool? isLoading}) {
    return OwnerState(
      bikes: bikes ?? this.bikes,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}