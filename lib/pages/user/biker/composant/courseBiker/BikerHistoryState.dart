import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';

class BikerHistoryState {
  final List<Race> allRaces;
  final bool isLoading;
  final String? errorMessage;

  BikerHistoryState({
    this.allRaces = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BikerHistoryState copyWith({
    List<Race>? allRaces,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BikerHistoryState(
      allRaces: allRaces ?? this.allRaces,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}