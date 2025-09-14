import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '/data/data.dart';

part 'update_note_response.g.dart';

@JsonSerializable()
class UpdateNoteResponse with EquatableMixin {
  UpdateNoteResponse({this.isSuccess, this.errorCode, this.message, this.data});

  factory UpdateNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateNoteResponseFromJson(json);
  bool? isSuccess;
  String? errorCode;
  String? message;
  NoteModel? data;

  Map<String, dynamic> toJson() => _$UpdateNoteResponseToJson(this);

  @override
  List<Object?> get props => [isSuccess, errorCode, message, data];

  UpdateNoteResponse copyWith({
    bool? isSuccess,
    String? errorCode,
    String? message,
    NoteModel? data,
  }) {
    return UpdateNoteResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
