import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/data/data.dart';
import '/domain/domain.dart';

part 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required this.authRepository, required this.storageRepository})
    : super(const SettingsState());

  final IAuthRepository authRepository;
  final IStorageRepository storageRepository;

  /// Kullanıcı bilgilerini yükle
  Future<void> loadUserInfo() async {
    emit(state.copyWith(status: SettingsStatus.loading));

    final result = await authRepository.getUserInfo();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (userInfo) => emit(
        state.copyWith(status: SettingsStatus.success, userInfo: userInfo),
      ),
    );
  }

  /// Çıkış yap
  Future<void> logout() async {
    emit(state.copyWith(status: SettingsStatus.loading));

    // Firebase'den çıkış yap
    final logoutResult = await authRepository.logoutUser();

    if (logoutResult.isSuccess) {
      // Storage'dan kullanıcı verilerini temizle
      await storageRepository.setIdToken(null);
      await storageRepository.setIsLogged();
      await storageRepository.setUsername();

      emit(state.copyWith(status: SettingsStatus.logoutSuccess));
    } else {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage:
              logoutResult.failure?.message ?? 'Çıkış yapılırken hata oluştu',
        ),
      );
    }
  }
}
