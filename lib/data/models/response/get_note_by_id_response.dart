import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '/data/data.dart';

part 'get_note_by_id_response.g.dart';

@JsonSerializable()
class GetNoteByIdResponse with EquatableMixin {
  GetNoteByIdResponse({
    this.isSuccess,
    this.errorCode,
    this.message,
    this.data,
  });

  factory GetNoteByIdResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNoteByIdResponseFromJson(json);
  bool? isSuccess;
  String? errorCode;
  String? message;
  NoteModel? data;

  Map<String, dynamic> toJson() => _$GetNoteByIdResponseToJson(this);

  @override
  List<Object?> get props => [isSuccess, errorCode, message, data];

  GetNoteByIdResponse copyWith({
    bool? isSuccess,
    String? errorCode,
    String? message,
    NoteModel? data,
  }) {
    return GetNoteByIdResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
