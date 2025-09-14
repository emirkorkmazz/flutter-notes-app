import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '/core/core.dart';
import '/data/data.dart';
import '/domain/domain.dart';

@Injectable()
class SyncService {
  SyncService({
    required this.noteRepository,
    required this.localNoteRepository,
    required this.localDatabaseClient,
    required this.connectivityService,
  }) {
    // NOT: Connectivity listener KAPATILDI
    // Çünkü manual refresh zaten sync yapıyor
    // Çifte sync engellemek için sadece manual sync kullanıyoruz
    debugPrint('🚫 Connectivity listener devre dışı - sadece manual sync');
  }

  final INoteRepository noteRepository;
  final ILocalNoteRepository localNoteRepository;
  final LocalDatabaseClient localDatabaseClient;
  final ConnectivityService connectivityService;

  bool _isSyncing = false;

  /// Pending operasyonları sync et
  Future<void> syncPendingOperations() async {
    if (_isSyncing) {
      debugPrint('🔄 Sync zaten devam ediyor, atlaniyor...');
      return;
    }

    if (!connectivityService.isConnected) {
      debugPrint('📵 İnternet bağlantısı yok, sync atlanıyor...');
      return;
    }

    _isSyncing = true;
    debugPrint('🔄 Sync işlemi başlatıldı...');

    try {
      // Önce takılı kalmış processing notları pending'e geri döndür
      await _cleanupProcessingNotes();

      // İlk olarak mevcut duplicate'ları temizle
      await localDatabaseClient.cleanupDuplicateNotes();

      // Pending operasyonları server'a gönder
      await _syncToServer();

      // NOT: _syncFromServer artık çağrılmıyor çünkü UI zaten server'dan alıyor
      // Sadece pending'leri sync ediyoruz, UI refresh'i kendisi yapacak

      // Son olarak duplicate notları tekrar temizle
      await localDatabaseClient.cleanupDuplicateNotes();

      debugPrint('✅ Sync işlemi tamamlandı');
    } on Exception catch (e) {
      debugPrint('❌ Sync işlemi başarısız: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Pending operasyonları server'a gönder
  Future<void> _syncToServer() async {
    debugPrint('🔄 _syncToServer başlatıldı');
    final pendingResult = await localNoteRepository.getPendingNotes();

    await pendingResult.fold(
      (failure) {
        debugPrint('❌ Pending notlar alınamadı: ${failure.message}');
      },
      (pendingNotes) async {
        debugPrint('📤 ${pendingNotes.length} pending operasyon bulundu');

        if (pendingNotes.isEmpty) {
          debugPrint('⏭️ Pending not yok, sync atlanıyor');
          return;
        }

        for (var i = 0; i < pendingNotes.length; i++) {
          final pendingNote = pendingNotes[i];
          debugPrint(
            '🔄 Pending not ${i + 1}/${pendingNotes.length}: ${pendingNote.title} (Local ID: ${pendingNote.id}, Server ID: ${pendingNote.serverId}, Status: ${pendingNote.syncStatus})',
          );
          await _syncSingleNote(pendingNote);
        }

        debugPrint('✅ _syncToServer tamamlandı');
      },
    );
  }

  /// Tek bir pending notu sync et
  Future<void> _syncSingleNote(LocalNoteModel pendingNote) async {
    try {
      switch (pendingNote.syncStatus) {
        case 'pending_create':
          await _handlePendingCreate(pendingNote);
        case 'pending_update':
          await _handlePendingUpdate(pendingNote);
        case 'pending_delete':
          await _handlePendingDelete(pendingNote);
        default:
          debugPrint('⚠️ Bilinmeyen sync status: ${pendingNote.syncStatus}');
      }
    } on Exception catch (e) {
      debugPrint('❌ Not sync edilirken hata: $e');
      // Hata durumunda sync status'u hata olarak işaretleyebiliriz
      // Şimdilik atlıyoruz
    }
  }

  /// Pending create işlemini handle et
  Future<void> _handlePendingCreate(LocalNoteModel pendingNote) async {
    debugPrint(
      "📤 Yeni not server'a gönderiliyor: ${pendingNote.title} (Local ID: ${pendingNote.id}, Server ID: ${pendingNote.serverId})",
    );

    // Eğer zaten server ID'si varsa, tekrar gönderme
    if (pendingNote.serverId != null) {
      debugPrint(
        "⚠️ Not zaten server ID'si var, atlaniyor: ${pendingNote.title} (Server ID: ${pendingNote.serverId})",
      );
      await localNoteRepository.updateSyncStatus(pendingNote.id!, 'synced');
      return;
    }

    // Önce sync status'u processing yap (tekrar gönderilmeyi önlemek için)
    await localNoteRepository.updateSyncStatus(pendingNote.id!, 'processing');
    debugPrint(
      '🔄 Not durumu processing yapıldı: ${pendingNote.title} (Local ID: ${pendingNote.id})',
    );

    final noteModel = pendingNote.toNoteModel();

    // Eğer tags null ise boş liste gönder
    final tags = noteModel.tags ?? <NoteTag>[];

    final result = await noteRepository.createNote(
      title: noteModel.title ?? '',
      content: noteModel.content ?? '',
      startDate: noteModel.startDate,
      endDate: noteModel.endDate,
      pinned: noteModel.pinned,
      tags: tags,
    );

    await result.fold(
      (failure) async {
        debugPrint("❌ Not server'a gönderilemedi: ${failure.message}");
        // Hata durumunda pending'e geri döndür
        await localNoteRepository.updateSyncStatus(
          pendingNote.id!,
          'pending_create',
        );
        debugPrint(
          "🔄 Not durumu pending_create'e geri döndürüldü: ${pendingNote.title}",
        );
      },
      (response) async {
        if (response.data?.id != null) {
          // Server'dan ID aldık, local'de server ID'yi güncelle
          // updateServerId zaten sync_status'u 'synced' yapar
          await localNoteRepository.updateServerId(
            pendingNote.id!,
            response.data!.id!,
          );
          debugPrint(
            "✅ Not server'a gönderildi, Local ID: ${pendingNote.id} -> Server ID: ${response.data!.id} (${pendingNote.title})",
          );
        } else {
          debugPrint("❌ Server response'da ID yok: ${pendingNote.title}");
        }
      },
    );
  }

  /// Pending update işlemini handle et
  Future<void> _handlePendingUpdate(LocalNoteModel pendingNote) async {
    if (pendingNote.serverId == null) {
      debugPrint("⚠️ Update edilecek notun server ID'si yok");
      return;
    }

    debugPrint("📤 Not güncelleme server'a gönderiliyor: ${pendingNote.title}");

    final noteModel = pendingNote.toNoteModel();

    // Eğer tags null ise boş liste gönder
    final tags = noteModel.tags ?? <NoteTag>[];

    final result = await noteRepository.updateNote(
      id: pendingNote.serverId!,
      title: noteModel.title ?? '',
      content: noteModel.content ?? '',
      startDate: noteModel.startDate,
      endDate: noteModel.endDate,
      pinned: noteModel.pinned,
      tags: tags,
    );

    await result.fold(
      (failure) {
        debugPrint(
          "❌ Not güncellemesi server'a gönderilemedi: ${failure.message}",
        );
      },
      (response) async {
        // Güncelleme başarılı, sync status'u güncelle
        await localNoteRepository.updateSyncStatus(pendingNote.id!, 'synced');
        debugPrint("✅ Not güncellemesi server'a gönderildi");
      },
    );
  }

  /// Pending delete işlemini handle et
  Future<void> _handlePendingDelete(LocalNoteModel pendingNote) async {
    if (pendingNote.serverId == null) {
      debugPrint("⚠️ Silinecek notun server ID'si yok");
      return;
    }

    debugPrint("📤 Not silme server'a gönderiliyor: ${pendingNote.title}");

    final result = await noteRepository.deleteNote(pendingNote.serverId!);

    await result.fold(
      (failure) {
        debugPrint("❌ Not silme server'a gönderilemedi: ${failure.message}");
      },
      (response) async {
        // Silme başarılı, local'den kalıcı olarak sil
        await localDatabaseClient.permanentDeleteNote(pendingNote.id!);
        debugPrint(
          "✅ Not silme server'a gönderildi ve local'den kalıcı olarak silindi",
        );
      },
    );
  }

  /// Manuel sync tetikle
  Future<void> forcSync() async {
    debugPrint('🔄 Manuel sync tetiklendi');
    await syncPendingOperations();
  }

  /// Takılı kalmış processing notları temizle
  Future<void> _cleanupProcessingNotes() async {
    try {
      final processingNotes = await localDatabaseClient.getProcessingNotes();
      for (final note in processingNotes) {
        // Processing durumundaki notları tekrar pending yapabilir veya sileriz
        if (note.syncStatus == 'processing') {
          // Eğer server_id varsa synced yap, yoksa pending_create yap
          if (note.serverId != null) {
            await localNoteRepository.updateSyncStatus(note.id!, 'synced');
            debugPrint('🔧 Processing not synced yapıldı: ${note.title}');
          } else {
            await localNoteRepository.updateSyncStatus(
              note.id!,
              'pending_create',
            );
            debugPrint(
              '🔧 Processing not pending_create yapıldı: ${note.title}',
            );
          }
        }
      }
    } on Exception catch (e) {
      debugPrint('❌ Processing notlar temizlenirken hata: $e');
    }
  }

  /// Service'i temizle
  void dispose() {
    // NOT: Connectivity subscription artık yok
    debugPrint('🧹 SyncService dispose edildi');
  }
}
