import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '/core/core.dart';

part 'update_note_request.g.dart';

@JsonSerializable()
class UpdateNoteRequest with EquatableMixin {
  UpdateNoteRequest({
    this.title,
    this.content,
    this.startDate,
    this.endDate,
    this.pinned,
    this.tags,
  });

  factory UpdateNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateNoteRequestFromJson(json);
  String? title;
  String? content;
  @JsonKey(name: 'start_date')
  String? startDate;
  @JsonKey(name: 'end_date')
  String? endDate;
  bool? pinned;
  List<NoteTag>? tags;

  Map<String, dynamic> toJson() => _$UpdateNoteRequestToJson(this);

  @override
  List<Object?> get props => [title, content, startDate, endDate, pinned, tags];

  UpdateNoteRequest copyWith({
    String? title,
    String? content,
    String? startDate,
    String? endDate,
    bool? pinned,
    List<NoteTag>? tags,
  }) {
    return UpdateNoteRequest(
      title: title ?? this.title,
      content: content ?? this.content,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pinned: pinned ?? this.pinned,
      tags: tags ?? this.tags,
    );
  }
}
