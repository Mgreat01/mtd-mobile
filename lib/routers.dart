import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moto_taxi_digital_mobile/pages/404/notFound.dart';
import 'package:moto_taxi_digital_mobile/pages/home/homePage.dart';
import 'package:moto_taxi_digital_mobile/pages/login/loginPage.dart';
import 'package:moto_taxi_digital_mobile/pages/login/passwordRecoveryPage.dart';
import 'package:moto_taxi_digital_mobile/pages/register/accountValidated/avPage.dart';
import 'package:moto_taxi_digital_mobile/pages/register/documentPage/kycPage.dart';
import 'package:moto_taxi_digital_mobile/pages/register/otp/otpPage.dart';
import 'package:moto_taxi_digital_mobile/pages/register/phoneNumber/phoneNumberPage.dart';
import 'package:moto_taxi_digital_mobile/pages/register/registerPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/bottom.dart';
import 'package:moto_taxi_digital_mobile/framework/cache/registrationProgressStore.dart';
import 'main.dart';
import 'pages/intro/appCtrl.dart';
import 'pages/intro/introPage.dart';
import 'utils/navigationUtils.dart';

final routerConfigProvider = Provider<GoRouter>((ref) {
  final navigatorKey = getIt<NavigationUtils>().navigatorKey;
  final registrationStore = RegistrationProgressStore();

  /*
   ROUTES RESTREINTES (Nécessitent un utilisateur connecté)
  */
  final authRoutes = [
    GoRoute(
      path: "/app/homee",
      name: 'home_pagee',
      builder: (ctx, state) => HomePage(),
    ),
    GoRoute(
      path: "/app/introUser",
      name: 'intro_UserPage',
      builder: (ctx, state) => const BottomNavBar(),
    ),
  ];

  /*
   ROUTES PUBLIQUES
  */
  final noAuthRoutes = [
    GoRoute(
      path: "/public/intro",
      name: 'intro_page',
      builder: (ctx, state) => const IntroPage(),
    ),
    GoRoute(
      path: "/public/pNumber",
      name: 'pnumber_page',
      builder: (ctx, state) => const PhoneNumberPage(),
    ),
    GoRoute(
      path: "/public/register",
      name: 'register_page',
      builder: (ctx, state) {
        final data =
            state.extra as Map<String, dynamic>? ??
            {'role': 'passenger', 'phone': ''};
        return RegisterPage(
          role: data['role'] ?? 'passenger',
          phone: data['phone'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/public/otp',
      name: 'otp_page',
      builder: (ctx, state) {
        final progress = registrationStore.read();
        final email = state.uri.queryParameters['email'] ?? progress?.email;
        final role = state.uri.queryParameters['role'] ?? progress?.role;
        if (email == null || role == null) return const LoginPage();
        return OTPPage(email: email, role: role);
      },
    ),
    GoRoute(
      path: "/public/login",
      name: 'login_page',
      builder: (ctx, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/public/forgot-password',
      name: 'forgot_password',
      builder: (ctx, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/public/reset-password',
      name: 'reset_password',
      builder: (ctx, state) =>
          ResetPasswordPage(initialEmail: state.extra as String?),
    ),
    GoRoute(
      path: "/public/kyc",
      name: 'kyc_page',
      builder: (ctx, state) => const KycPage(),
    ),
    GoRoute(
      path: "/public/AccountValidatedPage",
      name: 'AccountValidatedPage',
      builder: (ctx, state) => const AccountValidatedPage(),
    ),
  ];

  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: "/public/intro",
    redirect: (context, state) {
      final appState = ref.watch(appCtrlProvider);
      final user = appState.user;
      final isLoading = appState.isLoading == true;

      if (isLoading) return null;

      if (user != null) {
        final publicAuthPages = [
          '/public/login',
          '/public/register',
          '/public/pNumber',
          '/public/otp',
        ];

        if (publicAuthPages.contains(state.matchedLocation)) {
          return '/app/introUser';
        }
        return null;
      }

      if (user == null) {
        final progress = registrationStore.read();
        final isEntryPage =
            state.matchedLocation == '/public/intro' ||
            state.matchedLocation == '/public/login';

        if (isEntryPage && progress != null) {
          if (progress.step == RegistrationStep.otp) {
            return Uri(
              path: '/public/otp',
              queryParameters: {'email': progress.email, 'role': progress.role},
            ).toString();
          }
          return '/public/AccountValidatedPage';
        }

        if (state.matchedLocation == '/public/intro') {
          return '/public/login';
        }
        if (state.matchedLocation.startsWith('/app/')) {
          return '/public/login';
        }
        return null;
      }

      return null;
    },

    routes: [...noAuthRoutes, ...authRoutes],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});
