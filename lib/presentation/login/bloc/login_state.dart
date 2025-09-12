part of 'login_bloc.dart';

enum LoginStatus {
  unknown, // Başlangıç durumu, oturum durumu bilinmiyor.
  authenticated, // Kullanıcı başarıyla doğrulanmış.
  unAuthenticated, // Kullanıcı doğrulanamamış.
  loading, // Oturum durumu yükleniyor.
  failure, // Oturum açma işlemi başarısız oldu.
  edit, // Kullanıcı bilgileri düzenleniyor.
}

final class LoginState extends Equatable {
  ///
  const LoginState({
    this.email = '',
    this.password = '',
    this.isValid = false,
    this.status = LoginStatus.unknown,
    this.errorMessage = '',
  });

  /// Form Alanları
  final String email;
  final String password;

  ///
  final bool isValid;

  ///
  final LoginStatus status;

  /// Hata mesajı
  final String errorMessage;

  ///
  LoginState copyWith({
    String? email,
    String? password,
    bool? isValid,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, isValid, status, errorMessage];
}
