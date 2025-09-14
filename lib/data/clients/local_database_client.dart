import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/local/local_note_model.dart';

@Injectable()
class LocalDatabaseClient {
  static Database? _database;

  /// Database instance'ı al
  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  /// Database'i initialize et
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'noteapp.db');

    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Database tablolarını oluştur
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        title TEXT,
        content TEXT,
        start_date TEXT,
        end_date TEXT,
        pinned INTEGER DEFAULT 0,
        deleted INTEGER DEFAULT 0,
        tags TEXT,
        created_at TEXT,
        updated_at TEXT,
        sync_status TEXT DEFAULT 'synced',
        last_modified TEXT
      )
    ''');

    // Sync status için index
    await db.execute('''
      CREATE INDEX idx_sync_status ON notes(sync_status)
    ''');

    // Server ID için index
    await db.execute('''
      CREATE INDEX idx_server_id ON notes(server_id)
    ''');
  }

  /// Tüm notları getir
  Future<List<LocalNoteModel>> getAllNotes() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'deleted = ?',
      whereArgs: [0],
      orderBy: 'last_modified DESC',
    );

    return maps.map(LocalNoteModel.fromMap).toList();
  }

  /// Belirli sync durumundaki notları getir
  Future<List<LocalNoteModel>> getNotesBySyncStatus(String syncStatus) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'sync_status = ? AND deleted = ?',
      whereArgs: [syncStatus, 0],
      orderBy: 'last_modified DESC',
    );

    return maps.map(LocalNoteModel.fromMap).toList();
  }

  /// Pending (beklemede) olan notları getir
  Future<List<LocalNoteModel>> getPendingNotes() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'sync_status IN (?, ?, ?) AND deleted = ?',
      whereArgs: ['pending_create', 'pending_update', 'pending_delete', 0],
      orderBy: 'last_modified ASC', // En eski pending'den başla
    );

    debugPrint('📋 ${maps.length} pending not bulundu');
    return maps.map(LocalNoteModel.fromMap).toList();
  }

  /// Server ID'sine göre not getir
  Future<LocalNoteModel?> getNoteByServerId(String serverId) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return LocalNoteModel.fromMap(maps.first);
    }
    return null;
  }

  /// Title ve content'e göre not getir (duplicate kontrolü için)
  Future<LocalNoteModel?> getNoteByTitleAndContent(
    String title,
    String content,
  ) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title = ? AND content = ? AND deleted = ?',
      whereArgs: [title, content, 0],
      orderBy: 'last_modified DESC', // En yeni kaydı al
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return LocalNoteModel.fromMap(maps.first);
    }
    return null;
  }

  /// Processing durumundaki notları getir
  Future<List<LocalNoteModel>> getProcessingNotes() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'sync_status = ? AND deleted = ?',
      whereArgs: ['processing', 0],
      orderBy: 'last_modified DESC',
    );

    debugPrint('⚙️ ${maps.length} processing not bulundu');
    return maps.map(LocalNoteModel.fromMap).toList();
  }

  /// Not ekle
  Future<int> insertNote(LocalNoteModel note) async {
    final db = await database;
    return db.insert('notes', note.toMap());
  }

  /// Not güncelle (ID ile)
  Future<int> updateNote(LocalNoteModel note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Server ID ile not güncelle
  Future<int> updateNoteByServerId(LocalNoteModel note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'server_id = ?',
      whereArgs: [note.serverId],
    );
  }

  /// Not sil (soft delete)
  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.update(
      'notes',
      {
        'deleted': 1,
        'sync_status': 'pending_delete',
        'last_modified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Server ID ile not sil (soft delete)
  Future<int> deleteNoteByServerId(String serverId) async {
    final db = await database;
    return db.update(
      'notes',
      {
        'deleted': 1,
        'sync_status': 'pending_delete',
        'last_modified': DateTime.now().toIso8601String(),
      },
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
  }

  /// Not kalıcı olarak sil (hard delete)
  Future<int> permanentDeleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Sync durumunu güncelle
  Future<int> updateSyncStatus(int id, String syncStatus) async {
    final db = await database;
    return db.update(
      'notes',
      {
        'sync_status': syncStatus,
        'last_modified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Server ID'sini güncelle (create işlemi tamamlandığında)
  Future<int> updateServerId(int localId, String serverId) async {
    final db = await database;
    return db.update(
      'notes',
      {
        'server_id': serverId,
        'sync_status': 'synced',
        'last_modified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Tüm notları sil (veritabanını temizle)
  Future<int> clearAllNotes() async {
    final db = await database;
    return db.delete('notes');
  }

  /// Duplicate notları temizle (title ve content bazlı)
  Future<void> cleanupDuplicateNotes() async {
    final db = await database;

    // Aynı title ve content'e sahip notları bul
    final duplicates = await db.rawQuery('''
      SELECT title, content, MIN(id) as keep_id, COUNT(*) as count
      FROM notes 
      WHERE deleted = 0 AND title IS NOT NULL AND content IS NOT NULL
      GROUP BY title, content 
      HAVING COUNT(*) > 1
    ''');

    for (final duplicate in duplicates) {
      final title = duplicate['title']! as String;
      final content = duplicate['content']! as String;
      final keepId = duplicate['keep_id']! as int;
      final count = duplicate['count']! as int;

      // En eski kaydı tut, diğerlerini sil
      await db.delete(
        'notes',
        where: 'title = ? AND content = ? AND id != ? AND deleted = ?',
        whereArgs: [title, content, keepId, 0],
      );

      debugPrint('🧹 ${count - 1} duplicate title/content temizlendi: $title');
    }

    // Ayrıca aynı server_id'ye sahip notları da temizle
    final serverIdDuplicates = await db.rawQuery('''
      SELECT server_id, MIN(id) as keep_id, COUNT(*) as count
      FROM notes 
      WHERE server_id IS NOT NULL AND deleted = 0
      GROUP BY server_id 
      HAVING COUNT(*) > 1
    ''');

    for (final duplicate in serverIdDuplicates) {
      final serverId = duplicate['server_id']! as String;
      final keepId = duplicate['keep_id']! as int;
      final count = duplicate['count']! as int;

      // En eski kaydı tut, diğerlerini sil
      await db.delete(
        'notes',
        where: 'server_id = ? AND id != ? AND deleted = ?',
        whereArgs: [serverId, keepId, 0],
      );

      debugPrint('🧹 ${count - 1} duplicate server ID temizlendi: $serverId');
    }
  }

  /// Database'i kapat
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
