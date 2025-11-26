import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class NavigationUtils {
  late GlobalKey<NavigatorState> navigatorKey;

  NavigationUtils() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  // Navigation avec pushNamed (ajoute à la pile)
  Future<T?>? pushNamed<T>(String routeName, {Map<String, String> pathParameters = const {}, Map<String, dynamic> queryParameters = const {}, Object? extra}) {
    var context = navigatorKey.currentContext;
    return context?.pushNamed<T>(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  // Navigation avec push (URL directe)
  Future<T?>? push<T>(String routePath, {Object? extra}) {
    var context = navigatorKey.currentContext;
    return context?.push<T>(routePath, extra: extra);
  }

  // Navigation avec goNamed (remplace la pile)
  void goNamed(String routeName, {Map<String, String> pathParameters = const {}, Map<String, dynamic> queryParameters = const {}, Object? extra}) {
    var context = navigatorKey.currentContext;
    context?.goNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  // Navigation avec go (URL directe, remplace la pile)
  void go(String routePath, {Object? extra}) {
    var context = navigatorKey.currentContext;
    context?.go(routePath, extra: extra);
  }

  // Remplacement avec pushReplacementNamed
  void pushReplacementNamed(String routeName, {Map<String, String> pathParameters = const {}, Map<String, dynamic> queryParameters = const {}, Object? extra}) {
    var context = navigatorKey.currentContext;
    context?.pushReplacementNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  // Remplacement avec pushReplacement
  void pushReplacement(String routePath, {Object? extra}) {
    var context = navigatorKey.currentContext;
    context?.pushReplacement(routePath, extra: extra);
  }

  // Retour en arrière
  void pop([dynamic result]) {
    var context = navigatorKey.currentContext;
    if (context != null && canPop()) {
      context.pop(result);
    } else {
      // Exit app si on ne peut pas pop
      SystemNavigator.pop();
    }
  }

  // Vérifie si on peut revenir en arrière
  bool canPop() {
    var context = navigatorKey.currentContext;
    return context != null && GoRouter.of(context).canPop();
  }

  // Retour à la racine de la navigation
  void popToRoot() {
    var context = navigatorKey.currentContext;
    if (context != null) {
      while (GoRouter.of(context).canPop()) {
        context.pop();
      }
    }
  }

  // Obtient les paramètres de la route actuelle
  Map<String, String> get pathParameters {
    var context = navigatorKey.currentContext;
    return context != null ? GoRouterState.of(context).pathParameters : {};
  }

  // Obtient les query parameters de la route actuelle
  Map<String, String> get queryParameters {
    var context = navigatorKey.currentContext;
    return context != null ? GoRouterState.of(context).uri.queryParameters : {};
  }

  // Obtient les extra de la route actuelle
  Object? get extra {
    var context = navigatorKey.currentContext;
    return context != null ? GoRouterState.of(context).extra : null;
  }
}