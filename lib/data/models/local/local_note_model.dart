import 'package:equatable/equatable.dart';

import '/core/core.dart';
import '/data/data.dart';

/// Local veritabanında saklanacak not modeli
class LocalNoteModel with EquatableMixin {
  LocalNoteModel({
    this.id,
    this.serverId,
    this.title,
    this.content,
    this.startDate,
    this.endDate,
    this.pinned,
    this.deleted,
    this.tags,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastModified,
  });

  /// Map'ten oluştur (SQLite'dan)
  factory LocalNoteModel.fromMap(Map<String, dynamic> map) {
    return LocalNoteModel(
      id: map['id'] as int?,
      serverId: map['server_id'] as String?,
      title: map['title'] as String?,
      content: map['content'] as String?,
      startDate: map['start_date'] as String?,
      endDate: map['end_date'] as String?,
      pinned: (map['pinned'] as int?) == 1,
      deleted: (map['deleted'] as int?) == 1,
      tags: map['tags'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      syncStatus: map['sync_status'] as String?,
      lastModified: map['last_modified'] as String?,
    );
  }

  /// NoteModel'den oluştur
  factory LocalNoteModel.fromNoteModel(
    NoteModel noteModel, {
    String syncStatus = 'synced',
  }) {
    String? tagsString;
    if (noteModel.tags != null && noteModel.tags!.isNotEmpty) {
      tagsString = noteModel.tags!.map((tag) => tag.name).join(',');
    }

    return LocalNoteModel(
      serverId: noteModel.id,
      title: noteModel.title,
      content: noteModel.content,
      startDate: noteModel.startDate,
      endDate: noteModel.endDate,
      pinned: noteModel.pinned,
      deleted: noteModel.deleted,
      tags: tagsString,
      createdAt: noteModel.createdAt,
      updatedAt: noteModel.updatedAt,
      syncStatus: syncStatus,
      lastModified: DateTime.now().toIso8601String(),
    );
  }

  /// Local ID (SQLite auto increment)
  final int? id;

  /// Server'daki ID (null ise henüz server'a gönderilmemiş)
  final String? serverId;

  final String? title;
  final String? content;
  final String? startDate;
  final String? endDate;
  final bool? pinned;
  final bool? deleted;
  final String? tags; // JSON string olarak saklanacak
  final String? createdAt;
  final String? updatedAt;

  /// Sync durumu: 'synced', 'pending_create', 'pending_update', 'pending_delete'
  final String? syncStatus;

  /// Son değiştirilme zamanı
  final String? lastModified;

  /// Map'e çevir (SQLite için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'server_id': serverId,
      'title': title,
      'content': content,
      'start_date': startDate,
      'end_date': endDate,
      'pinned': (pinned ?? false) ? 1 : 0,
      'deleted': (deleted ?? false) ? 1 : 0,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
      'last_modified': lastModified,
    };
  }

  /// NoteModel'e çevir
  NoteModel toNoteModel() {
    List<NoteTag>? parsedTags;
    if (tags != null && tags!.isNotEmpty) {
      try {
        final tagNames = tags!.split(',');
        parsedTags =
            tagNames
                .map(
                  (name) => NoteTag.values.firstWhere(
                    (tag) => tag.name == name.trim(),
                    orElse: () => NoteTag.personal,
                  ),
                )
                .toList();
      } on Exception {
        parsedTags = null;
      }
    }

    return NoteModel(
      id: serverId,
      title: title,
      content: content,
      startDate: startDate,
      endDate: endDate,
      pinned: pinned,
      deleted: deleted,
      tags: parsedTags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  LocalNoteModel copyWith({
    int? id,
    String? serverId,
    String? title,
    String? content,
    String? startDate,
    String? endDate,
    bool? pinned,
    bool? deleted,
    String? tags,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
    String? lastModified,
  }) {
    return LocalNoteModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      content: content ?? this.content,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pinned: pinned ?? this.pinned,
      deleted: deleted ?? this.deleted,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  List<Object?> get props => [
    id,
    serverId,
    title,
    content,
    startDate,
    endDate,
    pinned,
    deleted,
    tags,
    createdAt,
    updatedAt,
    syncStatus,
    lastModified,
  ];
}
