import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_info_response.g.dart';

@JsonSerializable()
class UserInfoResponse with EquatableMixin {
  UserInfoResponse({this.id, this.email, this.createdAt});

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$UserInfoResponseFromJson(json);
  String? id;
  String? email;
  String? createdAt;

  Map<String, dynamic> toJson() => _$UserInfoResponseToJson(this);

  @override
  List<Object?> get props => [id, email, createdAt];

  UserInfoResponse copyWith({String? id, String? email, String? createdAt}) {
    return UserInfoResponse(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
