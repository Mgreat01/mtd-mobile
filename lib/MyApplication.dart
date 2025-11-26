// lib/MyApplication.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/providers/themeProvider.dart';
import 'package:moto_taxi_digital_mobile/routers.dart';
import 'package:moto_taxi_digital_mobile/utils/themes/appTheme.dart';

class MyApplication extends ConsumerStatefulWidget {
  const MyApplication({super.key});

  @override
  ConsumerState<MyApplication> createState() => _MyApplicationState();
}

class _MyApplicationState extends ConsumerState<MyApplication> {
  @override
  Widget build(BuildContext context) {
    final routerConfig = ref.watch(routerConfigProvider);
    final themeMode = ref.watch(themeProvider);

    // Sélectionne le ThemeData en fonction du mode
    final ThemeData currentTheme = themeMode == AppThemeMode.light
        ? AppTheme.lightTheme
        : AppTheme.darkTheme;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      // theme = ThemeData (obligatoire)
      theme: currentTheme,
      // darkTheme = ThemeData (obligatoire si tu veux utiliser ThemeMode.dark)
      darkTheme: AppTheme.darkTheme,
      // themeMode = ThemeMode (contrôle quel thème activer)
      themeMode: themeMode == AppThemeMode.light
          ? ThemeMode.light
          : ThemeMode.dark,
      routerConfig: routerConfig,
    );
  }
}