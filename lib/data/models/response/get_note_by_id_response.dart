import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_note_by_id_response.g.dart';

@JsonSerializable()
class GetNoteByIdResponse with EquatableMixin {
  GetNoteByIdResponse({
    this.id,
    this.title,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory GetNoteByIdResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNoteByIdResponseFromJson(json);
  String? id;
  String? title;
  String? content;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() => _$GetNoteByIdResponseToJson(this);

  @override
  List<Object?> get props => [id, title, content, createdAt, updatedAt];

  GetNoteByIdResponse copyWith({
    String? id,
    String? title,
    String? content,
    String? createdAt,
    String? updatedAt,
  }) {
    return GetNoteByIdResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
