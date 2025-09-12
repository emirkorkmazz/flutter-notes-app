import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/data/data.dart';
import '/domain/domain.dart';

part 'home_event.dart';
part 'home_state.dart';

@Injectable()
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.noteRepository}) : super(const HomeState()) {
    on<LoadNotes>(_onLoadNotes);
    on<RefreshNotes>(_onRefreshNotes);
    on<DeleteNote>(_onDeleteNote);
    on<SearchChanged>(_onSearchChanged);
  }

  final INoteRepository noteRepository;

  /// Notları yükle
  FutureOr<void> _onLoadNotes(LoadNotes event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));

    final result = await noteRepository.getNotes();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: HomeStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (GetNotesResponse response) {
        // Sadece bugün ve gelecek tarihli notları filtrele
        final filteredNotes = _filterNotesByDate(response.data ?? []);
        emit(
          state.copyWith(
            status: HomeStatus.success,
            notes: filteredNotes,
            errorMessage: '',
          ),
        );
      },
    );
  }

  /// Notları yenile (pull to refresh)
  FutureOr<void> _onRefreshNotes(
    RefreshNotes event,
    Emitter<HomeState> emit,
  ) async {
    // Refresh için loading state'ini göstermiyoruz
    final result = await noteRepository.getNotes();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: HomeStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (GetNotesResponse response) {
        // Sadece bugün ve gelecek tarihli notları filtrele
        final filteredNotes = _filterNotesByDate(response.data ?? []);
        emit(
          state.copyWith(
            status: HomeStatus.success,
            notes: filteredNotes,
            errorMessage: '',
          ),
        );
      },
    );
  }

  /// Not sil
  FutureOr<void> _onDeleteNote(
    DeleteNote event,
    Emitter<HomeState> emit,
  ) async {
    final result = await noteRepository.deleteNote(event.noteId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: HomeStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (void _) {
        // Not silindikten sonra listeyi yenile
        add(const LoadNotes());
      },
    );
  }

  /// Arama terimi değişti
  FutureOr<void> _onSearchChanged(
    SearchChanged event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(searchTerm: event.searchTerm));
  }

  /// Notları tarih aralığına göre filtrele
  /// Sadece bugün ve gelecek tarihli notları döndür
  List<NoteModel> _filterNotesByDate(List<NoteModel> notes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return notes.where((note) {
      // Eğer startDate yoksa, notu göster
      if (note.startDate == null || note.startDate!.isEmpty) {
        return true;
      }

      try {
        final startDate = DateTime.parse(note.startDate!);
        final noteDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );

        // Bugün ve gelecek tarihli notları göster
        return noteDate.isAtSameMomentAs(today) || noteDate.isAfter(today);
      } catch (e) {
        // Tarih parse edilemezse, notu göster
        return true;
      }
    }).toList();
  }
}
