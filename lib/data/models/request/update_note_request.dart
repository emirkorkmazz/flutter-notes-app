import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_note_request.g.dart';

@JsonSerializable()
class UpdateNoteRequest with EquatableMixin {
  UpdateNoteRequest({this.title, this.content});

  factory UpdateNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateNoteRequestFromJson(json);
  String? title;
  String? content;

  Map<String, dynamic> toJson() => _$UpdateNoteRequestToJson(this);

  @override
  List<Object?> get props => [title, content];

  UpdateNoteRequest copyWith({String? title, String? content}) {
    return UpdateNoteRequest(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}
