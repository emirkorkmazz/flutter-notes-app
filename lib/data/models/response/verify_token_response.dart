import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verify_token_response.g.dart';

@JsonSerializable()
class VerifyTokenResponse with EquatableMixin {
  VerifyTokenResponse({
    this.isSuccess,
    this.errorCode,
    this.message,
    this.data,
  });

  factory VerifyTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyTokenResponseFromJson(json);
  bool? isSuccess;
  String? errorCode;
  String? message;
  VerifyTokenData? data;

  Map<String, dynamic> toJson() => _$VerifyTokenResponseToJson(this);

  @override
  List<Object?> get props => [isSuccess, errorCode, message, data];

  VerifyTokenResponse copyWith({
    bool? isSuccess,
    String? errorCode,
    String? message,
    VerifyTokenData? data,
  }) {
    return VerifyTokenResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

@JsonSerializable()
class VerifyTokenData with EquatableMixin {
  VerifyTokenData({this.id, this.email, this.createdAt});

  factory VerifyTokenData.fromJson(Map<String, dynamic> json) =>
      _$VerifyTokenDataFromJson(json);
  String? id;
  String? email;
  String? createdAt;

  Map<String, dynamic> toJson() => _$VerifyTokenDataToJson(this);

  @override
  List<Object?> get props => [id, email, createdAt];

  VerifyTokenData copyWith({String? id, String? email, String? createdAt}) {
    return VerifyTokenData(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
