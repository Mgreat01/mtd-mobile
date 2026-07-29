import 'package:moto_taxi_digital_mobile/business/models/notification/appNotification.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/biker/biker.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';

abstract class BikerService {
  Future<List<Biker>> getAllBikers();
  Future<Biker> getBikerById(int id);
  Future<void> deleteBiker(int id);
  Future<List<Race>> getBikerRaces();
  Future<List<Biker>> getAvailableBikers();
  Future<dynamic> getBalance();
  Future<List<Race>> getCourses();
  Future<dynamic> getPrices();
  Future<RaceRouteModel?> getBikerPassengerTrack({
    required double lat,
    required double lng,
    required int raceId,
  });
  Future<void> updateLocation({
    required double lat,
    required double lng,
    required bool isActive,
  });
  Future<List<BikerMarkerData>> getActiveBikers();
  Future<List<AppNotification>> getNotifications();
}
