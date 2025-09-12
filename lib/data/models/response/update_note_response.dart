import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_note_response.g.dart';

@JsonSerializable()
class UpdateNoteResponse with EquatableMixin {
  UpdateNoteResponse({
    this.id,
    this.title,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory UpdateNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateNoteResponseFromJson(json);
  String? id;
  String? title;
  String? content;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() => _$UpdateNoteResponseToJson(this);

  @override
  List<Object?> get props => [id, title, content, createdAt, updatedAt];

  UpdateNoteResponse copyWith({
    String? id,
    String? title,
    String? content,
    String? createdAt,
    String? updatedAt,
  }) {
    return UpdateNoteResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
