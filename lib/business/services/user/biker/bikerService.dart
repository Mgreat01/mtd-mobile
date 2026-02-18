import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/biker/biker.dart';

abstract class BikerService {
  Future<List<Biker>> getAllBikers();
  Future<Biker> getBikerById(int id);
  Future<void> deleteBiker(int id);
  Future<List<dynamic>> getBikerRaces(int bikerId);
  Future<List<Biker>> getAvailableBikers();
  Future <dynamic> getBalance();
  Future <List<Race>> getCourses();
  Future <dynamic> getPrices();
}
