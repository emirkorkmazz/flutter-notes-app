import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'restore_note_response.g.dart';

@JsonSerializable()
class RestoreNoteResponse with EquatableMixin {
  RestoreNoteResponse({
    this.isSuccess,
    this.errorCode,
    this.message,
    this.data,
  });

  factory RestoreNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$RestoreNoteResponseFromJson(json);
  bool? isSuccess;
  String? errorCode;
  String? message;
  Data? data;

  Map<String, dynamic> toJson() => _$RestoreNoteResponseToJson(this);

  @override
  List<Object?> get props => [isSuccess, errorCode, message, data];

  RestoreNoteResponse copyWith({
    bool? isSuccess,
    String? errorCode,
    String? message,
    Data? data,
  }) {
    return RestoreNoteResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

@JsonSerializable()
class Data with EquatableMixin {
  Data({
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

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
  String? id;
  String? title;
  String? content;
  String? startDate;
  String? endDate;
  bool? pinned;
  bool? deleted;
  List<String>? tags;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() => _$DataToJson(this);

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

  Data copyWith({
    String? id,
    String? title,
    String? content,
    String? startDate,
    String? endDate,
    bool? pinned,
    bool? deleted,
    List<String>? tags,
    String? createdAt,
    String? updatedAt,
  }) {
    return Data(
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
