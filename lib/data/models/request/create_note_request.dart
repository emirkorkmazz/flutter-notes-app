import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_note_request.g.dart';

@JsonSerializable()
class CreateNoteRequest with EquatableMixin {
  CreateNoteRequest({this.title, this.content});

  factory CreateNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateNoteRequestFromJson(json);
  String? title;
  String? content;

  Map<String, dynamic> toJson() => _$CreateNoteRequestToJson(this);

  @override
  List<Object?> get props => [title, content];

  CreateNoteRequest copyWith({String? title, String? content}) {
    return CreateNoteRequest(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}
