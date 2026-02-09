import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/providers/themeProvider.dart';
import 'package:moto_taxi_digital_mobile/routers.dart';
import 'package:moto_taxi_digital_mobile/utils/themes/appTheme.dart';

class MyApplication extends ConsumerWidget {
  const MyApplication({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerConfig = ref.watch(routerConfigProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Moto Taxi Digital',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState == AppThemeMode.light
          ? ThemeMode.light
          : ThemeMode.dark,
      routerConfig: routerConfig,
    );
  }
}