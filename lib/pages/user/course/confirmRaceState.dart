import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';

class ConfirmRaceState {
  final bool isLoading;
  final String? errorMessage;
  final String destinationName;
  final String startAddress;
  final double amount;
  final BikerMarkerData? selectedBiker;
  final int priceListId;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  ConfirmRaceState({
    this.isLoading = false,
    this.errorMessage,
    required this.destinationName,
    required this.startAddress,
    required this.amount,
    this.selectedBiker,
    required this.priceListId,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
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
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    );
  }
}