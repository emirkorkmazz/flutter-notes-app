import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '/data/data.dart';

part 'get_notes_response.g.dart';

@JsonSerializable()
class GetNotesResponse with EquatableMixin {
  GetNotesResponse({this.isSuccess, this.errorCode, this.message, this.data});

  factory GetNotesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNotesResponseFromJson(json);
  bool? isSuccess;
  String? errorCode;
  String? message;
  List<NoteModel>? data;

  Map<String, dynamic> toJson() => _$GetNotesResponseToJson(this);

  @override
  List<Object?> get props => [isSuccess, errorCode, message, data];

  GetNotesResponse copyWith({
    bool? isSuccess,
    String? errorCode,
    String? message,
    List<NoteModel>? data,
  }) {
    return GetNotesResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
