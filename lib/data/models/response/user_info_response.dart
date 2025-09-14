import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_info_response.g.dart';

@JsonSerializable()
class UserInfoResponse with EquatableMixin {
  UserInfoResponse({this.isSuccess, this.errorCode, this.message, this.data});

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$UserInfoResponseFromJson(json);
  bool? isSuccess;
  String? errorCode;
  String? message;
  UserInfoData? data;

  Map<String, dynamic> toJson() => _$UserInfoResponseToJson(this);

  @override
  List<Object?> get props => [isSuccess, errorCode, message, data];

  UserInfoResponse copyWith({
    bool? isSuccess,
    String? errorCode,
    String? message,
    UserInfoData? data,
  }) {
    return UserInfoResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

@JsonSerializable()
class UserInfoData with EquatableMixin {
  UserInfoData({this.id, this.email, this.createdAt});

  factory UserInfoData.fromJson(Map<String, dynamic> json) =>
      _$UserInfoDataFromJson(json);
  String? id;
  String? email;
  String? createdAt;

  Map<String, dynamic> toJson() => _$UserInfoDataToJson(this);

  @override
  List<Object?> get props => [id, email, createdAt];

  UserInfoData copyWith({String? id, String? email, String? createdAt}) {
    return UserInfoData(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
