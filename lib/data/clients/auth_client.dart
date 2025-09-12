import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart' hide Headers;

import '/core/core.dart';
import '/data/data.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String baseUrl}) = _AuthClient;

  ///
  @POST(AppUrls.verifyToken)
  Future<VerifyTokenResponse> verifyToken();

  ///
  @GET(AppUrls.userInfo)
  Future<HttpResponse<UserInfoResponse>> userInfo();
}
