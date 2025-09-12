import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '../bloc/register_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        child: BlocConsumer<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state.status == RegisterStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Kayıt başarıyla tamamlandı! Lütfen giriş yapın.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              // Login sayfasına yönlendir
              context.go(AppRouteName.login.path);
            } else if (state.status == RegisterStatus.failure) {
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
                    const SizedBox(height: 20),

                    /// [1] Logo
                    _buildLogo(),
                    const SizedBox(height: 20),

                    /// [2] Title
                    _buildTitle(),
                    const SizedBox(height: 20),

                    /// [3] Email Field
                    _buildEmailField(),
                    const SizedBox(height: 10),

                    /// [4] Password Field
                    _buildPasswordField(),
                    const SizedBox(height: 10),

                    /// [5] Confirm Password Field
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 30),

                    /// [6] Register Button
                    _buildRegisterButton(context, state),
                    const SizedBox(height: 20),

                    /// [7] Divider
                    _buildDividerWithText(context),
                    const SizedBox(height: 20),

                    /// [8] Login Button
                    _buildLoginButton(context),
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
          'Kayıt Ol',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Yeni hesap oluşturun',
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
      enabledBorderColor: Colors.white,
      focusedBorderColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.white),
      prefix: const Icon(Icons.email_outlined, color: Colors.white),
      onChanged: (value) {
        context.read<RegisterBloc>().add(RegisterEmailChanged(value));
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
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
      onChanged: (value) {
        context.read<RegisterBloc>().add(RegisterPasswordChanged(value));
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

  Widget _buildConfirmPasswordField() {
    return AppTextField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      hintText: 'Şifrenizi tekrar girin',
      enabledBorderColor: Colors.white,
      focusedBorderColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.white),
      prefix: const Icon(Icons.lock_outlined, color: Colors.white),
      suffix: IconButton(
        icon: Icon(
          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        },
      ),
      onChanged: (value) {
        context.read<RegisterBloc>().add(RegisterConfirmPasswordChanged(value));
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifre tekrarı gerekli';
        }
        if (value.length < 6) {
          return 'Şifre en az 6 karakter olmalı';
        }
        if (value != _passwordController.text) {
          return 'Şifreler eşleşmiyor';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(BuildContext context, RegisterState state) {
    return AppElevatedButton(
      onPressed:
          state.status == RegisterStatus.loading
              ? null
              : () => _handleRegister(context, state),
      child:
          state.status == RegisterStatus.loading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : const Text(
                'Kayıt Ol',
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

  Widget _buildLoginButton(BuildContext context) {
    return AppElevatedButton(
      isSecondary: true,
      onPressed: () => _goLoginView(context),
      child: const Text(
        'Giriş Yap',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Register işlemini gerçekleştir
  void _handleRegister(BuildContext context, RegisterState state) {
    if (_formKey.currentState!.validate()) {
      context.read<RegisterBloc>().add(
        RegisterSubmitted(
          _emailController.text.trim(),
          _passwordController.text,
          _confirmPasswordController.text,
        ),
      );
    }
  }

  /// Login View'e yönlendir
  void _goLoginView(BuildContext context) =>
      context.go(AppRouteName.login.path);
}
