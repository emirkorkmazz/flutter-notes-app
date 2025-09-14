import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '/core/core.dart';

part 'note_model.g.dart';

@JsonSerializable()
class NoteModel with EquatableMixin {
  NoteModel({
    this.id,
    this.title,
    this.content,
    this.startDate,
    this.endDate,
    this.pinned,
    this.deleted,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);
  String? id;
  String? title;
  String? content;
  @JsonKey(name: 'start_date')
  String? startDate;
  @JsonKey(name: 'end_date')
  String? endDate;
  bool? pinned;
  bool? deleted;
  List<NoteTag>? tags;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'updated_at')
  String? updatedAt;

  Map<String, dynamic> toJson() => _$NoteModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    startDate,
    endDate,
    pinned,
    deleted,
    tags,
    createdAt,
    updatedAt,
  ];

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? startDate,
    String? endDate,
    bool? pinned,
    bool? deleted,
    List<NoteTag>? tags,
    String? createdAt,
    String? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pinned: pinned ?? this.pinned,
      deleted: deleted ?? this.deleted,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
