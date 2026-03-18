import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';

class ConfirmRaceState {
  final bool isLoading;
  final String? errorMessage;
  final String destinationName;
  final String startAddress;
  final double amount;
  final BikerMarkerData selectedBiker;
  final int priceListId;

  ConfirmRaceState({
    this.isLoading = false,
    this.errorMessage,
    required this.destinationName,
    required this.startAddress,
    required this.amount,
    required this.selectedBiker,
    required this.priceListId,
  });

  ConfirmRaceState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConfirmRaceState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      destinationName: destinationName,
      startAddress: startAddress,
      amount: amount,
      selectedBiker: selectedBiker,
      priceListId: priceListId,
    );
  }
}