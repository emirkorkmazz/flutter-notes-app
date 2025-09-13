import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '/core/core.dart';

part 'create_note_request.g.dart';

@JsonSerializable()
class CreateNoteRequest with EquatableMixin {
  CreateNoteRequest({
    this.title,
    this.content,
    this.startDate,
    this.endDate,
    this.pinned,
    this.tags,
  });

  factory CreateNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateNoteRequestFromJson(json);
  String? title;
  String? content;
  @JsonKey(name: 'start_date')
  String? startDate;
  @JsonKey(name: 'end_date')
  String? endDate;
  bool? pinned;
  List<NoteTag>? tags;

  Map<String, dynamic> toJson() => _$CreateNoteRequestToJson(this);

  @override
  List<Object?> get props => [title, content, startDate, endDate, pinned, tags];

  CreateNoteRequest copyWith({
    String? title,
    String? content,
    String? startDate,
    String? endDate,
    bool? pinned,
    List<NoteTag>? tags,
  }) {
    return CreateNoteRequest(
      title: title ?? this.title,
      content: content ?? this.content,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pinned: pinned ?? this.pinned,
      tags: tags ?? this.tags,
    );
  }
}
