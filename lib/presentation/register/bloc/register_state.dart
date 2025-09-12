part of 'register_bloc.dart';

enum RegisterStatus {
  unknown, // Başlangıç durumu
  loading, // Kayıt işlemi yükleniyor
  success, // Kayıt başarılı
  failure, // Kayıt başarısız
  edit, // Kullanıcı bilgileri düzenleniyor
}

final class RegisterState extends Equatable {
  const RegisterState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isValid = false,
    this.status = RegisterStatus.unknown,
    this.errorMessage = '',
  });

  /// Form Alanları
  final String email;
  final String password;
  final String confirmPassword;

  /// Form validasyonu
  final bool isValid;

  /// Durum
  final RegisterStatus status;

  /// Hata mesajı
  final String errorMessage;

  RegisterState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? isValid,
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    confirmPassword,
    isValid,
    status,
    errorMessage,
  ];
}
