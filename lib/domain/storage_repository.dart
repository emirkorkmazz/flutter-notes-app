import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/core.dart';

abstract class IStorageRepository {
  /// AuthInterceptor'da Token isteyen endpoint'lerin
  /// request header'ına ekleyeceğiz
  Future<String?> getIdToken();
  Future<void> setIdToken(String? value);

  /// Uygulamanın cihazda ilk defa açılıp-açılmadığını kontrol
  /// GoRouter'ın redirect parametresinde sorgulayacağız
  Future<bool?> getIsFirstTimeAppOpen();
  Future<void> setIsFirstTimeAppOpen({bool isFirstTimeAppOpen = true});

  /// Kullanıcının oturum açıp-açmadığını kontrol
  /// GoRouter'ın redirect parametresinde sorgulayacağız
  Future<bool?> getIsLogged();
  Future<void> setIsLogged({bool isLogged = false});

  /// Kullanıcının adını getir
  Future<String?> getUsername();
  Future<void> setUsername({String? username});

  /// Tema için kullanılacak
  Future<String?> getThemeMode();
  Future<void> setThemeMode({String? themeMode});

}

@Injectable(as: IStorageRepository)
class StorageRepository implements IStorageRepository {
  ///
  const StorageRepository({
    required this.securedStorage,
    required this.unsecuredStorage,
  });

  ///
  final FlutterSecureStorage securedStorage;
  final SharedPreferences unsecuredStorage;

  @override
  Future<String?> getIdToken() => securedStorage.read(
        key: AppStorage.idToken.key,
      );

  @override
  Future<void> setIdToken(String? value) => securedStorage.write(
        key: AppStorage.idToken.key,
        value: value,
      );

  @override
  Future<bool?> getIsFirstTimeAppOpen() async => unsecuredStorage.getBool(
        AppStorage.isFirstTimeAppOpen.key,
      );

  @override
  Future<void> setIsFirstTimeAppOpen({
    bool isFirstTimeAppOpen = false,
  }) async =>
      unsecuredStorage.setBool(
        AppStorage.isFirstTimeAppOpen.key,
        isFirstTimeAppOpen,
      );

  @override
  Future<bool?> getIsLogged() async => unsecuredStorage.getBool(
        AppStorage.isLoggedIn.key,
      );

  @override
  Future<void> setIsLogged({bool isLogged = false}) async =>
      unsecuredStorage.setBool(
        AppStorage.isLoggedIn.key,
        isLogged,
      );

  @override
  Future<String?> getUsername() async => unsecuredStorage.getString(
        AppStorage.username.key,
      );

  @override
  Future<void> setUsername({String? username}) async =>
      unsecuredStorage.setString(
        AppStorage.username.key,
        username ?? '',
      );

  @override
  Future<String?> getThemeMode() async => unsecuredStorage.getString(
        AppStorage.themeMode.key,
      );

  @override
  Future<void> setThemeMode({String? themeMode}) async =>
      unsecuredStorage.setString(
        AppStorage.themeMode.key,
        themeMode ?? '',
      );
}
