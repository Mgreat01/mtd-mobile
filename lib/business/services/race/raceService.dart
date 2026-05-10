import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';

abstract class RaceService{
Future <List<Race>> getRaces();
Future <List<Race>> showForCurrentUser();
Future <Race> createRace(Race race);
Future <Race> getRaceById(int id);
Future <int> deletedRace(int id);
Future <Race> completedRace( dynamic race);
Future <Race> updateRaceBiker(int id);
}