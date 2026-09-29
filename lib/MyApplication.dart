import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/pages/login/loginCtrl.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var ctrl = ref.read(loginControllerProvider.notifier);
      ctrl.getLocalUser();
    });
  }

  @override
  Widget build(BuildContext context) {
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