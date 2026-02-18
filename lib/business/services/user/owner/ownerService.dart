import 'package:moto_taxi_digital_mobile/business/models/bike/bike.dart';

abstract class OwnerService {
  Future <List<Bike>> getByOwner();
  Future <List<Bike>> getAvailableBike();
  Future <Bike> getAssignatedBike();
  Future <Map<String,dynamic>> stat();

}