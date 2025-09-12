import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/data/data.dart';
import '/domain/domain.dart';

part 'all_notes_state.dart';

@Injectable()
class AllNotesCubit extends Cubit<AllNotesState> {
  AllNotesCubit({required this.noteRepository}) : super(const AllNotesState());

  final INoteRepository noteRepository;

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
}
