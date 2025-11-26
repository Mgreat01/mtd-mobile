import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moto_taxi_digital_mobile/pages/404/notFound.dart';
import 'package:moto_taxi_digital_mobile/pages/home/homePage.dart';
import 'main.dart';
import 'pages/intro/appCtrl.dart';
import 'pages/intro/introPage.dart';
import 'utils/navigationUtils.dart';

final routerConfigProvider = Provider<GoRouter>((ref) {
  final navigatorKey = getIt<NavigationUtils>().navigatorKey;

  /*
   routes restreintes
  */
  final authRoutes = [
    GoRoute(
      path: "/app/home",
      name: 'home_page',
      builder: (ctx, state) {
        return HomePage();
      },
    ),
  ];

  /*
   routes publics
  */
  final noAuthRoutes = [
    GoRoute(
      path: "/public/intro",
      name: 'intro_page',
      builder: (ctx, state) {
        return IntroPage();
      },
    ),
  ];

  /*
  CONFIGURATION DES ROUTES
  */
  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: "/public/intro",
    redirect: (context, state) {
      final appState = ref.read(appCtrlProvider);
      final user = appState.user;
      final error = appState.error;
      final isLoading = user == null && error == null;

      //  Ne pas rediriger quand on est sur /public/intro
      if (state.matchedLocation == "/public/intro") {
        return null;
      }

      if (isLoading) return null;

      if (user != null && state.matchedLocation.startsWith("/public")) {
        return "/app/home";
      }

      if (user == null && state.matchedLocation.startsWith("/app")) {
        return "/app/home";
      }

      return null;
    },

    routes: [...noAuthRoutes, ...authRoutes],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});