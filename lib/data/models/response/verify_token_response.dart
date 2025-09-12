import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verify_token_response.g.dart';

@JsonSerializable()
class VerifyTokenResponse with EquatableMixin {
  VerifyTokenResponse({this.id, this.email, this.createdAt});

  factory VerifyTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyTokenResponseFromJson(json);
  String? id;
  String? email;
  String? createdAt;

  Map<String, dynamic> toJson() => _$VerifyTokenResponseToJson(this);

  @override
  List<Object?> get props => [id, email, createdAt];

  VerifyTokenResponse copyWith({String? id, String? email, String? createdAt}) {
    return VerifyTokenResponse(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
