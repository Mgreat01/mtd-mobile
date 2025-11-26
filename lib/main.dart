import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:moto_taxi_digital_mobile/MyApplication.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userLocalService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userNetworkService.dart';
import 'package:moto_taxi_digital_mobile/framework/user/userLocalServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/userNetworkServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/utils/navigationUtils.dart';
import 'package:get_storage/get_storage.dart';

GetIt getIt = GetIt.instance;

// configuration instance Implementations
void configureImplementations() {
  getIt.registerLazySingleton<UserNetworkService>(
        () => UserNetworkServiceImpl(),
  );
  getIt.registerLazySingleton<UserLocalService>(
          () => UserLocalServiceImpl()
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

  //chargement du fichier .env
  await dotenv.load(fileName: ".env");

  runApp(ProviderScope(child: MyApplication()));
}


