import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '/data/data.dart';

part 'create_note_response.g.dart';

@JsonSerializable()
class CreateNoteResponse with EquatableMixin {
  CreateNoteResponse({this.isSuccess, this.errorCode, this.message, this.data});

  factory CreateNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateNoteResponseFromJson(json);
  bool? isSuccess;
  String? errorCode;
  String? message;
  NoteModel? data;

  Map<String, dynamic> toJson() => _$CreateNoteResponseToJson(this);

  @override
  List<Object?> get props => [isSuccess, errorCode, message, data];

  CreateNoteResponse copyWith({
    bool? isSuccess,
    String? errorCode,
    String? message,
    NoteModel? data,
  }) {
    return CreateNoteResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
