import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/domain/domain.dart';

part 'login_event.dart';
part 'login_state.dart';

@Injectable()
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this.authRepository, required this.storageRepository})
    : super(const LoginState()) {
    ///
    on<LoginEmailChanged>(_onEmailChanged);

    ///
    on<LoginPasswordChanged>(_onPasswordChanged);

    ///
    on<LoginSubmitted>(_onSubmitted);
  }

  final IAuthRepository authRepository;
  final IStorageRepository storageRepository;

  /// [1 Email] alanı doldurulduğunda kontrol
  FutureOr<void> _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    ///
    emit(
      state.copyWith(
        email: event.email,
        status: LoginStatus.edit,
        isValid: _isFormValid(event.email, state.password),
      ),
    );
  }

  /// [2 Password] alanı doldurulduğunda kontrol
  FutureOr<void> _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    ///
    emit(
      state.copyWith(
        password: event.password,
        status: LoginStatus.edit,
        isValid: _isFormValid(state.email, event.password),
      ),
    );
  }

  FutureOr<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: LoginStatus.loading));

    final loginResult = await authRepository.loginUser(
      email: event.email,
      password: event.password,
    );

    await loginResult.fold(
      (failure) {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (verifyResponse) async {
        // Login başarılı, kullanıcı bilgilerini storage'a kaydet
        await storageRepository.setIsLogged(isLogged: true);
        await storageRepository.setUsername(
          username: verifyResponse.data?.email,
        );

        emit(state.copyWith(status: LoginStatus.authenticated));
      },
    );
  }

  /// Form validasyonu kontrolü
  bool _isFormValid(String email, String password) {
    return email.isNotEmpty &&
        email.contains('@') &&
        password.isNotEmpty &&
        password.length >= 6;
  }
}
