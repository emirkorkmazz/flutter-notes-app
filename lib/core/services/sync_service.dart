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
    required this.connectivityService,
  }) {
    // Bağlantı durumu değişikliklerini dinle
    _connectivitySubscription = connectivityService.connectionStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        debugPrint(
          '📡 İnternet bağlantısı tespit edildi, sync başlatılıyor...',
        );
        syncPendingOperations();
      }
    });
  }

  final INoteRepository noteRepository;
  final ILocalNoteRepository localNoteRepository;
  final ConnectivityService connectivityService;
  late final StreamSubscription<bool> _connectivitySubscription;

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
      // Önce server'dan güncel notları al ve local'e sync et
      await _syncFromServer();

      // Sonra pending operasyonları server'a gönder
      await _syncToServer();

      debugPrint('✅ Sync işlemi tamamlandı');
    } catch (e) {
      debugPrint('❌ Sync işlemi başarısız: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Server'dan notları al ve local'e sync et
  Future<void> _syncFromServer() async {
    try {
      debugPrint("📥 Server'dan notlar alınıyor...");
      final result = await noteRepository.getNotes();

      await result.fold(
        (failure) {
          debugPrint("❌ Server'dan notlar alınamadı: ${failure.message}");
        },
        (response) async {
          if (response.data != null) {
            debugPrint("📥 ${response.data!.length} not server'dan alındı");
            await localNoteRepository.syncNotesFromServer(response.data!);
            debugPrint("✅ Server notları local'e sync edildi");
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Server sync hatası: $e');
    }
  }

  /// Pending operasyonları server'a gönder
  Future<void> _syncToServer() async {
    final pendingResult = await localNoteRepository.getPendingNotes();

    await pendingResult.fold(
      (failure) {
        debugPrint('❌ Pending notlar alınamadı: ${failure.message}');
      },
      (pendingNotes) async {
        debugPrint('📤 ${pendingNotes.length} pending operasyon bulundu');

        for (final pendingNote in pendingNotes) {
          await _syncSingleNote(pendingNote);
        }
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
    } catch (e) {
      debugPrint('❌ Not sync edilirken hata: $e');
      // Hata durumunda sync status'u hata olarak işaretleyebiliriz
      // Şimdilik atlıyoruz
    }
  }

  /// Pending create işlemini handle et
  Future<void> _handlePendingCreate(LocalNoteModel pendingNote) async {
    debugPrint("📤 Yeni not server'a gönderiliyor: ${pendingNote.title}");

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
      (failure) {
        debugPrint("❌ Not server'a gönderilemedi: ${failure.message}");
      },
      (response) async {
        if (response.data?.id != null) {
          // Server'dan ID aldık, local'de server ID'yi güncelle
          await localNoteRepository.updateServerId(
            pendingNote.id!,
            response.data!.id!,
          );
          debugPrint("✅ Not server'a gönderildi, ID: ${response.data!.id}");
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
        await localNoteRepository.updateSyncStatus(pendingNote.id!, 'deleted');
        debugPrint("✅ Not silme server'a gönderildi");
      },
    );
  }

  /// Manuel sync tetikle
  Future<void> forcSync() async {
    debugPrint('🔄 Manuel sync tetiklendi');
    await syncPendingOperations();
  }

  /// Service'i temizle
  void dispose() {
    _connectivitySubscription.cancel();
  }
}
