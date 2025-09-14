part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, failure, logoutSuccess }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.userInfo,
    this.errorMessage = '',
  });

  final SettingsStatus status;
  final UserInfoResponse? userInfo;
  final String errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    UserInfoResponse? userInfo,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      userInfo: userInfo ?? this.userInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, userInfo, errorMessage];
}
