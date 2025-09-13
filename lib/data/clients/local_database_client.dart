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
      where: 'sync_status IN (?, ?, ?)',
      whereArgs: ['pending_create', 'pending_update', 'pending_delete'],
      orderBy: 'last_modified ASC', // En eski pending'den başla
    );

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

  /// Database'i kapat
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
