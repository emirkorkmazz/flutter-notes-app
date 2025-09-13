import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '/domain/domain.dart';
import '/presentation/presentation.dart';

/// Uygulamanın Ana Navigator'unu yönetmesi için GlobalKey.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bottom Navigation Bar'ını yönetmesi için GlobalKey.
final shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  /// Ana Navigator anahtarını bu parametreye veriyoruz.
  navigatorKey: rootNavigatorKey,

  /// Başlangıç konumu
  initialLocation: '/',

  /// Debug için logları etkinleştir
  debugLogDiagnostics: true,

  /// Route Guard
  redirect: _routeGuard,

  /// Rotalar
  routes: _routes,
);

List<RouteBase> get _routes {
  return [
    // Root rotayı '/landing'e yönlendirin
    GoRoute(path: '/', redirect: (context, state) => '/landing'),

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

    /// Shell Route - Bottom Navigation Bar ile Ana Sayfalar
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
      routes: [
        /// Dashboard Ekranı için Rota
        GoRoute(
          path: AppRouteName.home.path,
          name: AppRouteName.home.withoutSlash,
          builder: (context, state) => const HomeView(),
        ),

        /// Tüm Notlar Ekranı için Rota
        GoRoute(
          path: AppRouteName.allNotes.path,
          name: AppRouteName.allNotes.withoutSlash,
          builder: (context, state) => const AllNotesView(),
        ),

        /// Ayarlar Ekranı için Rota
        GoRoute(
          path: AppRouteName.settings.path,
          name: AppRouteName.settings.withoutSlash,
          builder: (context, state) => const SettingsView(),
        ),
      ],
    ),

    /// Not Ekle Ekranı için Rota (Bottom bar olmadan)
    GoRoute(
      path: AppRouteName.addNote.path,
      name: AppRouteName.addNote.withoutSlash,
      builder: (context, state) => const AddNoteView(),
    ),

    /// Not Düzenle Ekranı için Rota (Bottom bar olmadan)
    GoRoute(
      path: AppRouteName.editNote.path,
      name: AppRouteName.editNote.withoutSlash,
      builder: (context, state) {
        final noteId = state.pathParameters['noteId']!;
        final title = state.uri.queryParameters['title'] ?? '';
        final content = state.uri.queryParameters['content'] ?? '';
        final startDateRaw = state.uri.queryParameters['startDate'];
        final endDateRaw = state.uri.queryParameters['endDate'];
        final pinned = state.uri.queryParameters['pinned'] == 'true';
        final tagsString = state.uri.queryParameters['tags'] ?? '';
        final tags =
            tagsString.isEmpty
                ? <NoteTag>[]
                : tagsString
                    .split(',')
                    .map(
                      (tagName) => NoteTag.values.firstWhere(
                        (tag) => tag.name == tagName,
                        orElse: () => NoteTag.work,
                      ),
                    )
                    .toList();

        // Tarih formatını dönüştür (ISO format'tan DD/MM/YYYY formatına)
        String? startDate;
        String? endDate;

        if (startDateRaw != null && startDateRaw.isNotEmpty) {
          try {
            final date = DateTime.parse(startDateRaw);
            startDate =
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          } catch (e) {
            startDate = startDateRaw; // Parse edilemezse orijinal değeri kullan
          }
        }

        if (endDateRaw != null && endDateRaw.isNotEmpty) {
          try {
            final date = DateTime.parse(endDateRaw);
            endDate =
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          } catch (e) {
            endDate = endDateRaw; // Parse edilemezse orijinal değeri kullan
          }
        }

        return EditNoteView(
          noteId: noteId,
          initialTitle: title,
          initialContent: content,
          initialStartDate: startDate,
          initialEndDate: endDate,
          initialPinned: pinned,
          initialTags: tags,
        );
      },
    ),
  ];
}

FutureOr<String?> _routeGuard(BuildContext context, GoRouterState state) async {
  final storageRepository = getIt<IStorageRepository>();

  /// Uygulamanın İlk Kez Açılıp Açılmadığını Kontrol Etme
  final isFirstTimeAppOpen =
      (await storageRepository.getIsFirstTimeAppOpen()) ?? true;

  /// Kullanıcının Giriş Yapıp Yapmadığını Kontrol Etme
  final isLoggedIn = (await storageRepository.getIsLogged()) ?? false;

  /// Kullanıcının Bulunduğu Sayfanın Yolunu Alma
  final currentLocation = state.matchedLocation;

  /// Genel Erişilebilir Sayfaların Listesini Tanımlama
  final publicPaths = <String>[
    AppRouteName.landing.path,
    AppRouteName.login.path,
    AppRouteName.register.path,
  ];

  /// [Durum 1] Uygulama İlk Kez Açılıyorsa [isFirstTimeAppOpen == true]
  if (isFirstTimeAppOpen) {
    // Eğer kullanıcı sayfalarda değilse, onu /landing sayfasına yönlendir
    if (!publicPaths.contains(currentLocation)) {
      log("Kullanıcı ilk kez açılışta, LandingView'e yönlendiriliyor.");
      return AppRouteName.landing.path;
    } else {
      //  yönlendirme yapma
      return null;
    }
  }

  /// Buradan itibaren, [isFirstTimeAppOpen == false]

  /// [Durum 2]  Kullanıcı Giriş Yapmış ve Landing Sayfasındaysa
  if (isLoggedIn && currentLocation == AppRouteName.landing.path) {
    log(
      "Kullanıcı giriş yapmış, LandingView'dan DashboardView'e yönlendiriliyor.",
    );
    return AppRouteName.home.path;
  }

  /// [Durum 3] Kullanıcı Giriş Yapmamış ve Yetkisiz Sayfada Değilse
  if (!isLoggedIn && !publicPaths.contains(currentLocation)) {
    log("Kullanıcı giriş yapmamış, LoginView'e yönlendiriliyor.");
    return AppRouteName.login.path;
  }

  /// [Durum 4]: Kullanıcı Giriş Yapmış ve Login veya Signup Sayfasındaysa
  if (isLoggedIn &&
      (currentLocation == AppRouteName.login.path ||
          currentLocation == AppRouteName.register.path)) {
    log("Kullanıcı zaten giriş yapmış, DashboardView'e yönlendiriliyor.");
    return AppRouteName.home.path;
  }

  /// [Varsayılan Durum] Yönlendirme yapma, mevcut sayfada kal
  return null;
}
