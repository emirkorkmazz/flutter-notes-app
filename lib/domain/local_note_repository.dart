import 'package:injectable/injectable.dart';

import '/core/core.dart';
import '/data/data.dart';

abstract class ILocalNoteRepository {
  /// Tüm local notları getir
  Future<Result<List<NoteModel>>> getLocalNotes();

  /// Local not kaydet
  Future<Result<void>> saveLocalNote(
    NoteModel note, {
    String syncStatus = 'synced',
  });

  /// Local notu güncelle
  Future<Result<void>> updateLocalNote(
    NoteModel note, {
    String syncStatus = 'synced',
  });

  /// Local notu sil
  Future<Result<void>> deleteLocalNote(String noteId);

  /// Pending (beklemede) olan notları getir
  Future<Result<List<LocalNoteModel>>> getPendingNotes();

  /// Sync durumunu güncelle
  Future<Result<void>> updateSyncStatus(int localId, String syncStatus);

  /// Server ID'sini güncelle (create işlemi tamamlandığında)
  Future<Result<void>> updateServerId(int localId, String serverId);

  /// Server'dan gelen notları local'e kaydet
  Future<Result<void>> syncNotesFromServer(List<NoteModel> serverNotes);

  /// Local veritabanını temizle
  Future<Result<void>> clearLocalNotes();
}

@Injectable(as: ILocalNoteRepository)
class LocalNoteRepository implements ILocalNoteRepository {
  const LocalNoteRepository({required this.localDatabaseClient});

  final LocalDatabaseClient localDatabaseClient;

  @override
  Future<Result<List<NoteModel>>> getLocalNotes() async {
    try {
      final localNotes = await localDatabaseClient.getAllNotes();
      final noteModels =
          localNotes.map((localNote) => localNote.toNoteModel()).toList();
      return Result.success(noteModels);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Local notlar alınırken hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<void>> saveLocalNote(
    NoteModel note, {
    String syncStatus = 'synced',
  }) async {
    try {
      final localNote = LocalNoteModel.fromNoteModel(
        note,
        syncStatus: syncStatus,
      );
      await localDatabaseClient.insertNote(localNote);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Local not kaydedilirken hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<void>> updateLocalNote(
    NoteModel note, {
    String syncStatus = 'synced',
  }) async {
    try {
      // Önce server ID'sine göre mevcut local note'u bul
      final existingNote = await localDatabaseClient.getNoteByServerId(
        note.id!,
      );

      if (existingNote != null) {
        final updatedNote = LocalNoteModel.fromNoteModel(
          note,
          syncStatus: syncStatus,
        ).copyWith(
          id: existingNote.id, // Local ID'yi koru
        );
        await localDatabaseClient.updateNote(updatedNote);
      } else {
        // Yoksa yeni kayıt oluştur
        await saveLocalNote(note, syncStatus: syncStatus);
      }

      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Local not güncellenirken hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteLocalNote(String noteId) async {
    try {
      await localDatabaseClient.deleteNoteByServerId(noteId);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Local not silinirken hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<List<LocalNoteModel>>> getPendingNotes() async {
    try {
      final pendingNotes = await localDatabaseClient.getPendingNotes();
      return Result.success(pendingNotes);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Pending notlar alınırken hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<void>> updateSyncStatus(int localId, String syncStatus) async {
    try {
      await localDatabaseClient.updateSyncStatus(localId, syncStatus);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Sync durumu güncellenirken hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<void>> updateServerId(int localId, String serverId) async {
    try {
      await localDatabaseClient.updateServerId(localId, serverId);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Server ID güncellenirken hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<void>> syncNotesFromServer(List<NoteModel> serverNotes) async {
    try {
      // Önce tüm local notları al
      final localNotes = await localDatabaseClient.getAllNotes();
      final localServerIds =
          localNotes
              .where((note) => note.serverId != null)
              .map((note) => note.serverId!)
              .toSet();

      // Server'dan gelen her not için
      for (final serverNote in serverNotes) {
        if (serverNote.id != null) {
          final existingNote = await localDatabaseClient.getNoteByServerId(
            serverNote.id!,
          );

          if (existingNote != null) {
            // Mevcut not varsa güncelle (eğer sync status pending değilse)
            if (existingNote.syncStatus == 'synced') {
              final updatedNote = LocalNoteModel.fromNoteModel(
                serverNote,
              ).copyWith(id: existingNote.id);
              await localDatabaseClient.updateNote(updatedNote);
            }
          } else {
            // Yeni not ise ekle
            await localDatabaseClient.insertNote(
              LocalNoteModel.fromNoteModel(serverNote),
            );
          }

          localServerIds.remove(serverNote.id);
        }
      }

      // Server'da olmayan ancak local'de olan notları sil
      // (Sadece sync'lenmiş olanları, pending olanları dokunma)
      for (final serverId in localServerIds) {
        final localNote = await localDatabaseClient.getNoteByServerId(serverId);
        if (localNote != null && localNote.syncStatus == 'synced') {
          await localDatabaseClient.deleteNoteByServerId(serverId);
        }
      }

      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Server notları sync edilirken hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<void>> clearLocalNotes() async {
    try {
      await localDatabaseClient.clearAllNotes();
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Local notlar temizlenirken hata oluştu: $e'),
      );
    }
  }
}
