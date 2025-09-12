import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '/domain/domain.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    ///
    return const Scaffold(
      ///
      body: _LandingViewBody(),
    );
  }
}

class _LandingViewBody extends StatelessWidget {
  const _LandingViewBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          /// [1] Logo
          _buildLogo(),
          const SizedBox(height: 50),

          /// [2] Text Message
          _buildLandingTextMessage(),
          const SizedBox(height: 10),

          /// [3] SignUp Button
          _buildSignupButton(context),
          const SizedBox(height: 10),

          /// [4] Divider
          _buildDividerWithText(context),
          const SizedBox(height: 10),

          /// [5] Login Button
          _buildLoginButton(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Center(child: Assets.icons.icAppLogo.image(width: 175, height: 175));
  }

  Widget _buildLandingTextMessage() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Noteapp'e Hoşgeldiniz", style: TextStyle(fontSize: 18)),
        Text(
          'Lütfen giriş yapınız veya kayıt olunuz.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSignupButton(BuildContext context) {
    return AppElevatedButton(
      onPressed: () {
        _goSignupView(context);
        _storeFirstAppOpenStatus();
      },
      child: Text(
        'Kayıt Ol',
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
        ),
      ),
    );
  }

  Widget _buildDividerWithText(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: Theme.of(context).colorScheme.primary,
            indent: 20,
            endIndent: 10,
          ),
        ),
        const Text(
          'veya',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Theme.of(context).colorScheme.primary,
            indent: 10,
            endIndent: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return AppElevatedButton(
      isSecondary: true,
      onPressed: () {
        _goLoginView(context);
        _storeFirstAppOpenStatus();
      },
      child: Text(
        'Giriş Yap',
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
        ),
      ),
    );
  }

  /// Register View'e yönlendir
  void _goSignupView(BuildContext context) =>
      context.go(AppRouteName.register.path);

  /// Login View'e yönlendir
  void _goLoginView(BuildContext context) =>
      context.go(AppRouteName.login.path);

  Future<void> _storeFirstAppOpenStatus() async {
    /// Uygulama cihazda ilk defa açıldığı için isFirstTimeAppOpen'ı [false] yap
    /// Böylece kullanıcı her açılışta bu sayfayı tekrar görmesin
    await getIt<IStorageRepository>().setIsFirstTimeAppOpen(
      isFirstTimeAppOpen: false,
    );
  }
}
