import 'package:injectable/injectable.dart';

import '/core/core.dart';
import '/data/data.dart';

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
  const NoteRepository({required this.noteClient});

  final NoteClient noteClient;

  @override
  Future<Result<GetNotesResponse>> getNotes() async {
    try {
      final response = await noteClient.getNotes();

      if (response.response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          const AuthFailure(message: 'Notlar yüklenirken hata oluştu'),
        );
      }
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Beklenmeyen bir hata oluştu: $e'),
      );
    }
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
    try {
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
        return Result.success(response.data);
      } else {
        return Result.failure(
          const AuthFailure(message: 'Not oluşturulurken hata oluştu'),
        );
      }
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Beklenmeyen bir hata oluştu: $e'),
      );
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
    try {
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
        return Result.success(response.data);
      } else {
        return Result.failure(
          const AuthFailure(message: 'Not güncellenirken hata oluştu'),
        );
      }
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Beklenmeyen bir hata oluştu: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteNote(String id) async {
    try {
      final response = await noteClient.deleteNote(id);

      if (response.response.statusCode == 200 ||
          response.response.statusCode == 204) {
        return Result.success(null);
      } else {
        return Result.failure(
          const AuthFailure(message: 'Not silinirken hata oluştu'),
        );
      }
    } on Exception catch (e) {
      return Result.failure(
        AuthFailure(message: 'Beklenmeyen bir hata oluştu: $e'),
      );
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
