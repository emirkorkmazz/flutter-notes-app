import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '/core/core.dart';
import '/data/data.dart';
import 'local_note_repository.dart';

abstract class INoteRepository {
  /// Tüm notları getir
  Future<Result<GetNotesResponse>> getNotes();

  /// Not oluştur
  Future<Result<CreateNoteResponse>> createNote({
    required String title,
    required String content,
    String? startDate,
    String? endDate,
    bool? pinned,
    List<NoteTag>? tags,
  });

  /// Not güncelle
  Future<Result<UpdateNoteResponse>> updateNote({
    required String id,
    required String title,
    required String content,
    String? startDate,
    String? endDate,
    bool? pinned,
    List<NoteTag>? tags,
  });

  /// Not sil
  Future<Result<void>> deleteNote(String id);

  /// ID ile not getir
  Future<Result<GetNoteByIdResponse>> getNoteById(String id);

  /// Not geri yükle
  Future<Result<void>> restoreNote(String id);
}

@Injectable(as: INoteRepository)
class NoteRepository implements INoteRepository {
  const NoteRepository({
    required this.noteClient,
    required this.localNoteRepository,
    required this.connectivityService,
  });

  final NoteClient noteClient;
  final ILocalNoteRepository localNoteRepository;
  final ConnectivityService connectivityService;

  @override
  Future<Result<GetNotesResponse>> getNotes() async {
    try {
      // Manuel bağlantı kontrolü yap (ilk kez çalışma durumu için)
      final hasConnection = await connectivityService.checkConnection();

      // Eğer internet varsa server'dan al
      if (hasConnection) {
        debugPrint("🌐 Internet bağlantısı var, server'dan notlar alınıyor...");
        final response = await noteClient.getNotes();

        if (response.response.statusCode == 200) {
          // Server'dan başarıyla alındı, local'e kaydet
          if (response.data.data != null) {
            await localNoteRepository.syncNotesFromServer(response.data.data!);
          }
          return Result.success(response.data);
        } else {
          // Server hatası, local'den al
          return await _getNotesFromLocal();
        }
      } else {
        // İnternet yok, local'den al
        debugPrint("📱 Internet bağlantısı yok, local'den notlar alınıyor...");
        return await _getNotesFromLocal();
      }
    } on Exception catch (e) {
      // Hata durumunda local'den al
      debugPrint("Server'dan notlar alınırken hata: $e, local'den alınıyor...");
      return _getNotesFromLocal();
    }
  }

  /// Local'den notları al
  Future<Result<GetNotesResponse>> _getNotesFromLocal() async {
    debugPrint('💾 Local veritabanından notlar alınıyor...');
    final localResult = await localNoteRepository.getLocalNotes();

    return localResult.fold<Result<GetNotesResponse>>(
      Result<GetNotesResponse>.failure,
      (List<NoteModel> notes) {
        debugPrint("💾 Local'den ${notes.length} not alındı");
        return Result.success(
          GetNotesResponse(
            isSuccess: true,
            message: "Notlar local'den alındı",
            data: notes,
          ),
        );
      },
    );
  }

  @override
  Future<Result<CreateNoteResponse>> createNote({
    required String title,
    required String content,
    String? startDate,
    String? endDate,
    bool? pinned,
    List<NoteTag>? tags,
  }) async {
    // Önce local'e kaydet
    final newNote = NoteModel(
      id: null, // Local'de server ID yok
      title: title,
      content: content,
      startDate: startDate,
      endDate: endDate,
      pinned: pinned,
      tags: tags,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    try {
      // Eğer internet varsa server'a gönder
      if (connectivityService.isConnected) {
        final request = CreateNoteRequest(
          title: title,
          content: content,
          startDate: startDate,
          endDate: endDate,
          pinned: pinned,
          tags: tags,
        );
        final response = await noteClient.createNote(request);

        if (response.response.statusCode == 201) {
          // Server'da başarıyla oluşturuldu, local'e sync olarak kaydet
          final serverNote = newNote.copyWith(id: response.data.data?.id);
          await localNoteRepository.saveLocalNote(
            serverNote,
            syncStatus: 'synced',
          );
          return Result.success(response.data);
        } else {
          // Server hatası, local'e pending olarak kaydet
          await localNoteRepository.saveLocalNote(
            newNote,
            syncStatus: 'pending_create',
          );
          return Result.failure(
            const AuthFailure(
              message: "Not server'a gönderilemedi, offline olarak kaydedildi",
            ),
          );
        }
      } else {
        // İnternet yok, local'e pending olarak kaydet
        await localNoteRepository.saveLocalNote(
          newNote,
          syncStatus: 'pending_create',
        );

        // Offline için mock response oluştur
        final mockResponse = CreateNoteResponse(
          isSuccess: true,
          message: 'Not offline olarak kaydedildi',
          data: newNote,
        );
        return Result.success(mockResponse);
      }
    } on Exception catch (e) {
      // Hata durumunda local'e pending olarak kaydet
      debugPrint(
        "Server'a not gönderilirken hata: $e, local'e kaydediliyor...",
      );
      await localNoteRepository.saveLocalNote(
        newNote,
        syncStatus: 'pending_create',
      );

      // Offline için mock response oluştur
      final mockResponse = CreateNoteResponse(
        isSuccess: true,
        message: 'Not offline olarak kaydedildi',
        data: newNote,
      );
      return Result.success(mockResponse);
    }
  }

  @override
  Future<Result<UpdateNoteResponse>> updateNote({
    required String id,
    required String title,
    required String content,
    String? startDate,
    String? endDate,
    bool? pinned,
    List<NoteTag>? tags,
  }) async {
    // Güncellenmiş not modeli oluştur
    final updatedNote = NoteModel(
      id: id,
      title: title,
      content: content,
      startDate: startDate,
      endDate: endDate,
      pinned: pinned,
      tags: tags,
      updatedAt: DateTime.now().toIso8601String(),
    );

    try {
      // Eğer internet varsa server'a gönder
      if (connectivityService.isConnected) {
        final request = UpdateNoteRequest(
          title: title,
          content: content,
          startDate: startDate,
          endDate: endDate,
          pinned: pinned,
          tags: tags,
        );
        final response = await noteClient.updateNote(id, request);

        if (response.response.statusCode == 200) {
          // Server'da başarıyla güncellendi, local'e sync olarak kaydet
          await localNoteRepository.updateLocalNote(
            updatedNote,
            syncStatus: 'synced',
          );
          return Result.success(response.data);
        } else {
          // Server hatası, local'e pending olarak kaydet
          await localNoteRepository.updateLocalNote(
            updatedNote,
            syncStatus: 'pending_update',
          );
          return Result.failure(
            const AuthFailure(
              message:
                  "Not server'da güncellenemedi, offline olarak kaydedildi",
            ),
          );
        }
      } else {
        // İnternet yok, local'e pending olarak kaydet
        await localNoteRepository.updateLocalNote(
          updatedNote,
          syncStatus: 'pending_update',
        );

        // Offline için mock response oluştur
        final mockResponse = UpdateNoteResponse(
          isSuccess: true,
          message: 'Not offline olarak güncellendi',
          data: updatedNote,
        );
        return Result.success(mockResponse);
      }
    } on Exception catch (e) {
      // Hata durumunda local'e pending olarak kaydet
      debugPrint(
        "Server'da not güncellenirken hata: $e, local'e kaydediliyor...",
      );
      await localNoteRepository.updateLocalNote(
        updatedNote,
        syncStatus: 'pending_update',
      );

      // Offline için mock response oluştur
      final mockResponse = UpdateNoteResponse(
        isSuccess: true,
        message: 'Not offline olarak güncellendi',
        data: updatedNote,
      );
      return Result.success(mockResponse);
    }
  }

  @override
  Future<Result<void>> deleteNote(String id) async {
    try {
      // Eğer internet varsa server'dan sil
      if (connectivityService.isConnected) {
        final response = await noteClient.deleteNote(id);

        if (response.response.statusCode == 200 ||
            response.response.statusCode == 204) {
          // Server'dan başarıyla silindi, local'den de sil
          await localNoteRepository.deleteLocalNote(id);
          return Result.success(null);
        } else {
          // Server hatası, local'de pending delete olarak işaretle
          await localNoteRepository.deleteLocalNote(id);
          return Result.failure(
            const AuthFailure(
              message: "Not server'dan silinemedi, offline olarak işaretlendi",
            ),
          );
        }
      } else {
        // İnternet yok, local'de pending delete olarak işaretle
        await localNoteRepository.deleteLocalNote(id);
        return Result.success(null);
      }
    } on Exception catch (e) {
      // Hata durumunda local'de pending delete olarak işaretle
      debugPrint(
        "Server'dan not silinirken hata: $e, local'de işaretleniyor...",
      );
      await localNoteRepository.deleteLocalNote(id);
      return Result.success(null);
    }
  }

  @override
  Future<Result<GetNoteByIdResponse>> getNoteById(String id) async {
    try {
      final response = await noteClient.getNoteById(id);

      if (response.response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          const AuthFailure(message: 'Not yüklenirken hata oluştu'),
        );
      }
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Beklenmeyen bir hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<RestoreNoteResponse>> restoreNote(String id) async {
    try {
      final response = await noteClient.restoreNote(id);

      if (response.response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          const AuthFailure(message: 'Not yüklenirken hata oluştu'),
        );
      }
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Beklenmeyen bir hata oluştu: $e'),
      );
    }
  }
}
