import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delete_note_response.g.dart';

@JsonSerializable()
class DeleteNoteResponse with EquatableMixin {
  DeleteNoteResponse({this.isSuccess, this.errorCode, this.message, this.data});

  factory DeleteNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteNoteResponseFromJson(json);
  bool? isSuccess;
  String? errorCode;
  String? message;
  dynamic data;

  Map<String, dynamic> toJson() => _$DeleteNoteResponseToJson(this);

  @override
  List<Object?> get props => [isSuccess, errorCode, message, data];

  DeleteNoteResponse copyWith({
    bool? isSuccess,
    String? errorCode,
    String? message,
    dynamic data,
  }) {
    return DeleteNoteResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
