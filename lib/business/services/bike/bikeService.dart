import 'package:moto_taxi_digital_mobile/business/models/bike/bike.dart';

abstract class BikeService {
  Future<List<Bike>> getAllBikes();
  Future<Bike> getBikeById(int id);
  Future<Bike> createBike(Bike bike);
  Future<Bike> updateBike(int id, Bike bike);
  Future<void> deleteBike(int id);
  Future<List<Bike>> getBikesByOwner(int ownerId);
  Future<List<Bike>> getBikesByBiker(int? bikerId);
  Future<List<Bike>> getAvailableBikes();
  Future<Map<String, dynamic>> getStats();
}
