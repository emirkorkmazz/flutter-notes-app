import 'package:dio/dio.dart';

import '/core/core.dart';
import '/domain/domain.dart';

class AppInterceptor extends Interceptor {
  const AppInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    /// Diğer tüm endpoint'ler için accessToken eklenir.
    final token = await getIt<IStorageRepository>().getIdToken();

    ///
    if (token != null && token.isNotEmpty) {
      /// Alınan token'ı Authorization header'ına ekle
      options.headers['Authorization'] = 'Bearer $token';
    }

    /// İstek devam etsin
    return handler.next(options);
  }

  /// [Response Interceptor:]
  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    /// Yanıt devam etsin
    return handler.next(response);
  }

  /// [Error Interceptor]
  /// Dio kütüphanesinden bir hata aldığında çağrılır.
  @override
  Future<void> onError(
    DioException dioException,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 Unauthorized hatası kontrolü
    if (dioException.response?.statusCode == 401) {
      try {
        // AuthRepository'den yeni token al
        final authResult = await getIt<IAuthRepository>().getIdToken();

        if (authResult.isSuccess) {
          final newToken = authResult.data!;

          // Yeni token'ı storage'a kaydet
          await getIt<IStorageRepository>().setIdToken(newToken);

          // Orijinal isteği yeni token ile tekrar gönder
          final options = dioException.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          try {
            final dio = Dio();
            final response = await dio.fetch<dynamic>(options);
            return handler.resolve(response);
          } on DioException {
            // Yeniden deneme başarısız olursa orijinal hatayı döndür
            return handler.next(dioException);
          }
        }
      } on Exception {
        // Token yenileme başarısız olursa orijinal hatayı döndür
        return handler.next(dioException);
      }
    }

    /// Diğer HTTP hataları için standart hata işleme devam eder.
    return handler.next(dioException);
  }
}
