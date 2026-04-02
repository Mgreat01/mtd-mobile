import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/main.dart'; // Pour getIt
import 'bikerState.dart';

class BikerController extends StateNotifier<BikerState> {
  final BikerService _bikerService = getIt.get<BikerService>();
  final Ref ref;
  StreamSubscription<Position>? _positionSubscription;

  BikerController(this.ref) : super(BikerState()) {
    refreshData();
  }

  // --- LOGIQUE DE SERVICE & GPS ---

  Future<void> toggleService() async {
    if (!state.isOnline) {
      bool hasPermission = await _handleLocationPermission();
      if (hasPermission) {
        state = state.copyWith(isOnline: true);
        _startLocationTracking();
      }
    } else {
      _stopLocationTracking();
      state = state.copyWith(isOnline: false);
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _startLocationTracking() async {
    _positionSubscription?.cancel();

    try {
      Position lastKnown = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
      _sendPositionToServer(lastKnown); // Envoi initial
    } catch (e) {
      print("GPS Error: $e");
    }


    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _sendPositionToServer(position);
    });
  }

Future<void> _sendPositionToServer(Position position) async {
    state = state.copyWith(
      currentPosition: LatLng(position.latitude, position.longitude),
    );


    if (state.isOnline) {
      await _bikerService.updateLocation(
        lat: position.latitude,
        lng: position.longitude,
        isActive: true,
      );
    }
  }

void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;

   _bikerService.updateLocation(
      lat: state.currentPosition.latitude,
      lng: state.currentPosition.longitude,
      isActive: false,
    );
  }

   Future<void> refreshData() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        _bikerService.getBalance(),
        _bikerService.getCourses(),
        _bikerService.getPrices(),
      ]);

      final walletBalance = results[0].toString();
      final List<Race> allRaces = results[1] as List<Race>;
      final List<dynamic> priceLists = results[2] as List<dynamic>;


      final String today = DateTime.now().toIso8601String().split('T')[0];
      final finishedToday = allRaces.where((r) =>
      r.status == 'completed' && r.date.toString().contains(today)
      ).toList();

      // 2. Calcul du revenu
      double dailyTotal = 0.0;
      for (var race in finishedToday) {
        final priceObj = priceLists.firstWhere(
              (p) => p['id'].toString() == race.priceListId.toString(),
          orElse: () => null,
        );
        if (priceObj != null) {
          dailyTotal += double.tryParse(priceObj['base_fare'].toString()) ?? 0.0;
        }
      }

      state = state.copyWith(
        walletBalance: "$walletBalance CDF",
        races: allRaces,
        completedRacesCount: finishedToday.where((r) => r.status == 'completed').length,
        dailyRevenue: dailyTotal,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Erreur BikerController: $e");
    }
  }


}


final bikerControllerProvider = StateNotifierProvider.autoDispose<BikerController, BikerState>((ref) {
  return BikerController(ref);
});