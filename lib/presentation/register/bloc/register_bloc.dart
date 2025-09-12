import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/domain/domain.dart';

part 'register_event.dart';
part 'register_state.dart';

@Injectable()
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({required this.authRepository, required this.storageRepository})
    : super(const RegisterState()) {
    ///
    on<RegisterEmailChanged>(_onEmailChanged);

    ///
    on<RegisterPasswordChanged>(_onPasswordChanged);

    ///
    on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);

    ///
    on<RegisterSubmitted>(_onSubmitted);
  }

  final IAuthRepository authRepository;
  final IStorageRepository storageRepository;

  /// [1 Email] alanı doldurulduğunda kontrol
  FutureOr<void> _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    ///
    emit(
      state.copyWith(
        email: event.email,
        status: RegisterStatus.edit,
        isValid: _isFormValid(
          event.email,
          state.password,
          state.confirmPassword,
        ),
        errorMessage: '',
      ),
    );
  }

  /// [2 Password] alanı doldurulduğunda kontrol
  FutureOr<void> _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    ///
    emit(
      state.copyWith(
        password: event.password,
        status: RegisterStatus.edit,
        isValid: _isFormValid(
          state.email,
          event.password,
          state.confirmPassword,
        ),
        errorMessage: '',
      ),
    );
  }

  /// [3 Confirm Password] alanı doldurulduğunda kontrol
  FutureOr<void> _onConfirmPasswordChanged(
    RegisterConfirmPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    ///
    emit(
      state.copyWith(
        confirmPassword: event.confirmPassword,
        status: RegisterStatus.edit,
        isValid: _isFormValid(
          state.email,
          state.password,
          event.confirmPassword,
        ),
        errorMessage: '',
      ),
    );
  }

  FutureOr<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (!state.isValid) return;

    // Şifre eşleşme kontrolü
    if (event.password != event.confirmPassword) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'Şifreler eşleşmiyor',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    final registerResult = await authRepository.registerUser(
      email: event.email,
      password: event.password,
    );

    await registerResult.fold(
      (failure) {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (verifyResponse) async {
        // Kayıt başarılı - kullanıcı logout edildi, login sayfasına yönlendirilecek
        emit(state.copyWith(status: RegisterStatus.success));
      },
    );
  }

  /// Form validasyonu kontrolü
  bool _isFormValid(String email, String password, String confirmPassword) {
    return email.isNotEmpty &&
        email.contains('@') &&
        password.isNotEmpty &&
        password.length >= 6 &&
        confirmPassword.isNotEmpty &&
        confirmPassword.length >= 6;
  }
}
