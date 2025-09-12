import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_notes_response.g.dart';

@JsonSerializable()
class GetNotesResponse with EquatableMixin {
  GetNotesResponse({
    this.id,
    this.title,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory GetNotesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNotesResponseFromJson(json);
  String? id;
  String? title;
  String? content;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() => _$GetNotesResponseToJson(this);

  @override
  List<Object?> get props => [id, title, content, createdAt, updatedAt];

  GetNotesResponse copyWith({
    String? id,
    String? title,
    String? content,
    String? createdAt,
    String? updatedAt,
  }) {
    return GetNotesResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
