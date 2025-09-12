import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/core.dart';
import '/data/data.dart';

@module
abstract class RegisterModule {
  ///
  @singleton
  Dio get dio =>
      Dio(BaseOptions(baseUrl: 'http://localhost:8000'))
        ..interceptors.addAll([
          const AppInterceptor(),
          if (kDebugMode)
            PrettyDioLogger(
              requestHeader: true,
              requestBody: true,
              responseHeader: true,
            ),
        ]);

  ///
  @singleton
  FlutterSecureStorage get securedStorage => const FlutterSecureStorage();

  @preResolve
  Future<SharedPreferences> get unsecuredStorage =>
      SharedPreferences.getInstance();

  @singleton
  AuthClient get authClient => AuthClient(dio);

  @singleton
  NoteClient get noteClient => NoteClient(dio);

  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
}
