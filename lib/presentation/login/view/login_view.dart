import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '../bloc/login_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.imBackgroundFirst.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.authenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Giriş başarıyla tamamlandı!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Ana sayfaya yönlendir
              context.go(AppRouteName.home.path);
            } else if (state.status == LoginStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 60),

                    /// [1] Logo
                    _buildLogo(),
                    const SizedBox(height: 50),

                    /// [2] Title
                    _buildTitle(),
                    const SizedBox(height: 30),

                    /// [3] Email Field
                    _buildEmailField(),
                    const SizedBox(height: 10),

                    /// [4] Password Field
                    _buildPasswordField(),
                    const SizedBox(height: 20),

                    /// [5] Login Button
                    _buildLoginButton(context, state),
                    const SizedBox(height: 20),

                    /// [6] Divider
                    _buildDividerWithText(context),
                    const SizedBox(height: 20),

                    /// [7] Register Button
                    _buildRegisterButton(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(child: Assets.icons.icAppLogo.image(width: 120, height: 120));
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giriş Yap',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Hesabınıza giriş yapın',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      hintText: 'ornek@email.com',
      textInputAction: TextInputAction.next,
      enabledBorderColor: Colors.white,
      focusedBorderColor: Colors.white,

      hintStyle: const TextStyle(color: Colors.white),
      prefix: const Icon(Icons.email_outlined, color: Colors.white),
      onChanged: (value) {
        context.read<LoginBloc>().add(LoginEmailChanged(value));
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'E-posta adresi gerekli';
        }
        if (!value.contains('@')) {
          return 'Geçerli bir e-posta adresi girin';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return AppTextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      enabledBorderColor: Colors.white,
      focusedBorderColor: Colors.white,
      hintText: 'Şifrenizi girin',
      hintStyle: const TextStyle(color: Colors.white),
      prefix: const Icon(Icons.lock_outlined, color: Colors.white),
      suffix: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.black,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
      onChanged: (value) {
        context.read<LoginBloc>().add(LoginPasswordChanged(value));
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifre gerekli';
        }
        if (value.length < 6) {
          return 'Şifre en az 6 karakter olmalı';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    return AppElevatedButton(
      onPressed:
          state.status == LoginStatus.loading
              ? null
              : () => _handleLogin(context, state),
      child:
          state.status == LoginStatus.loading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : const Text(
                'Giriş Yap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildRegisterButton(BuildContext context) {
    return AppElevatedButton(
      isSecondary: true,
      onPressed: () => _goRegisterView(context),
      child: const Text(
        'Kayıt Ol',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Login işlemini gerçekleştir
  void _handleLogin(BuildContext context, LoginState state) {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
        LoginSubmitted(_emailController.text.trim(), _passwordController.text),
      );
    }
  }

  /// Register View'e yönlendir
  void _goRegisterView(BuildContext context) =>
      context.go(AppRouteName.register.path);
}
