import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:moto_taxi_digital_mobile/MyApplication.dart';
import 'package:moto_taxi_digital_mobile/business/services/bike/bikeService.dart';
import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/owner/ownerService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userLocalService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userNetworkService.dart';
import 'package:moto_taxi_digital_mobile/framework/bike/bikeServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/race/raceServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/biker/bikerServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/owner/ownerServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/userLocalServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/userNetworkServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';
import 'package:moto_taxi_digital_mobile/utils/navigationUtils.dart';
import 'package:get_storage/get_storage.dart';

GetIt getIt = GetIt.instance;

// configuration instance Implementations
void configureImplementations() {

  getIt.registerLazySingleton<OwnerService>(
      ()=> OwnerServiceImpl(),
  );
  getIt.registerLazySingleton<UserNetworkService>(
        () => UserNetworkServiceImpl(),
  );
  getIt.registerLazySingleton<UserLocalService>(
          () => UserLocalServiceImpl(box: GetStorage())
  );
  getIt.registerLazySingleton<BikerService>(
        () => BikerServiceImpl(),
  );
  getIt.registerLazySingleton<BikeService>(
        () => BikeServiceImpl(),
  );

  getIt.registerLazySingleton<RaceService>(
        () => RaceServiceImpl(),
  );

  getIt.registerLazySingleton<NavigationUtils>(() => NavigationUtils());
}

void main() async{
  //initialisation de certaines fonctionnalités Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // configuration des Implementations
  configureImplementations();

  // initialisation du GetStorage pour stocker les donnees en local
  await GetStorage.init();

  //chargement du fichier .env initialisation globale
  await AppConfig.initialize();

  runApp(ProviderScope(child: MyApplication()));
}


