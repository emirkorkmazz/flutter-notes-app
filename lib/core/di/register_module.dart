import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/core.dart';

@module
abstract class RegisterModule {
  ///
  @singleton
  Dio get dio => Dio(
        BaseOptions(
          baseUrl: EnvConf.apiUrl,
        ),
      );

  ///
  @singleton
  FlutterSecureStorage get securedStorage => const FlutterSecureStorage();


  @preResolve
  Future<SharedPreferences> get unsecuredStorage =>
      SharedPreferences.getInstance();
}
