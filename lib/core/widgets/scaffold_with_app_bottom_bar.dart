import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: child,
      bottomNavigationBar:
          _shouldShowBottomNav(context)
              ? AppBottomBar(
                currentIndex: _calculateSelectedIndex(context),
                onTap: (index) => _onItemTapped(index, context),
              )
              : null,
    );
  }

  bool _shouldShowBottomNav(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    // Sadece ana route'larda bottom navigation bar'ı göster
    return location == AppRouteName.allNotes.path ||
        location == AppRouteName.home.path ||
        location == AppRouteName.settings.path;
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRouteName.allNotes.path)) return 0;
    if (location.startsWith(AppRouteName.home.path)) return 1;
    if (location.startsWith(AppRouteName.settings.path)) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.pushReplacement(AppRouteName.allNotes.path);
      case 1:
        context.pushReplacement(AppRouteName.home.path);

      case 2:
        context.pushReplacement(AppRouteName.settings.path);
    }
  }
}
