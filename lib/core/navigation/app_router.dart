import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '/presentation/presentation.dart';

/// Uygulamanın Ana Navigator'unu yönetmesi için GlobalKey.
final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  /// Ana Navigator anahtarını bu parametreye veriyoruz.
  navigatorKey: rootNavigatorKey,

  /// Başlangıç konumu
  initialLocation: '/',

  /// Debug için logları etkinleştir
  debugLogDiagnostics: true,

  /// Rotalar
  routes: _routes,
);

List<RouteBase> get _routes {
  return [
    // Root rotayı '/landing'e yönlendirin
    GoRoute(
      path: '/',
      redirect: (context, state) => '/landing',
    ),

    /// Landing Ekranı için Rota
    GoRoute(
      path: AppRouteName.landing.path,
      name: AppRouteName.landing.withoutSlash,
      builder: (context, state) => const LandingView(),
    ),

    /// Giriş Yap Ekranı için Rota
    GoRoute(
      path: AppRouteName.login.path,
      name: AppRouteName.login.withoutSlash,
      builder: (context, state) => const LoginView(),
    ),

    /// Kaydol Ekranı için Rota
    GoRoute(
      path: AppRouteName.register.path,
      name: AppRouteName.register.withoutSlash,
      builder: (context, state) => const RegisterView(),
    ),

    /// Dashboard Ekranı için Rota
    GoRoute(
      path: AppRouteName.home.path,
      name: AppRouteName.home.withoutSlash,
      builder: (context, state) => const HomeView(),
    ),
  ];
}
