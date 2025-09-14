import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/core/core.dart';
import '/data/data.dart';
import '/domain/domain.dart';

part 'all_notes_state.dart';

@Injectable()
class AllNotesCubit extends Cubit<AllNotesState> {
  AllNotesCubit({required this.noteRepository, required this.syncService})
    : super(const AllNotesState());

  final INoteRepository noteRepository;
  final SyncService syncService;

  /// Tüm notları yükle
  Future<void> loadAllNotes() async {
    emit(state.copyWith(status: AllNotesStatus.loading));

    final result = await noteRepository.getNotes();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AllNotesStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (GetNotesResponse response) {
        emit(
          state.copyWith(
            status: AllNotesStatus.success,
            notes: response.data ?? [],
            errorMessage: '',
          ),
        );
      },
    );
  }

  /// Tüm notları yenile (pull to refresh)
  Future<void> refreshAllNotes() async {
    // Önce manuel sync tetikle
    await syncService.forcSync();

    // Refresh için loading state'ini göstermiyoruz
    final result = await noteRepository.getNotes();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AllNotesStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (GetNotesResponse response) {
        emit(
          state.copyWith(
            status: AllNotesStatus.success,
            notes: response.data ?? [],
            errorMessage: '',
          ),
        );
      },
    );
  }

  /// Not sil
  Future<void> deleteNote(String noteId) async {
    final result = await noteRepository.deleteNote(noteId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AllNotesStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (void _) {
        // Not silindikten sonra listeyi yenile
        loadAllNotes();
      },
    );
  }

  /// Arama terimi değişti
  void searchChanged(String searchTerm) {
    emit(state.copyWith(searchTerm: searchTerm));
  }

  /// Notu geçici olarak kaldır (undo için)
  void temporarilyRemoveNote(String noteId) {
    final updatedNotes =
        state.notes.where((note) => note.id != noteId).toList();
    emit(state.copyWith(notes: updatedNotes));
  }

  /// Notu geri ekle (undo için)
  void restoreNote(NoteModel note) {
    final updatedNotes = [...state.notes, note];
    emit(state.copyWith(notes: updatedNotes));
  }

  /// AI önerisi al
  Future<void> getAiSuggestion(String noteId) async {
    emit(
      state.copyWith(
        aiSuggestionStatus: AiSuggestionStatus.loading,
        aiSuggestionError: '',
      ),
    );

    final result = await noteRepository.getAiSuggestions(noteId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            aiSuggestionStatus: AiSuggestionStatus.failure,
            aiSuggestionError: failure.message,
          ),
        );
      },
      (GetAiSuggestionResponse response) {
        emit(
          state.copyWith(
            aiSuggestionStatus: AiSuggestionStatus.success,
            aiSuggestion: response.data,
            aiSuggestionError: '',
          ),
        );
      },
    );
  }

  /// AI önerisi state'ini temizle
  void clearAiSuggestion() {
    emit(
      state.copyWith(
        aiSuggestionStatus: AiSuggestionStatus.initial,
        aiSuggestionError: '',
      ),
    );
  }
}
