import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_note_response.g.dart';

@JsonSerializable()
class CreateNoteResponse with EquatableMixin {
  CreateNoteResponse({
    this.id,
    this.title,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory CreateNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateNoteResponseFromJson(json);
  String? id;
  String? title;
  String? content;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() => _$CreateNoteResponseToJson(this);

  @override
  List<Object?> get props => [id, title, content, createdAt, updatedAt];

  CreateNoteResponse copyWith({
    String? id,
    String? title,
    String? content,
    String? createdAt,
    String? updatedAt,
  }) {
    return CreateNoteResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
