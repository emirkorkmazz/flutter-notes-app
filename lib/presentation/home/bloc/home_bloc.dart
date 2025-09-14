import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/core/core.dart';
import '/data/data.dart';
import '/domain/domain.dart';

part 'home_event.dart';
part 'home_state.dart';

@Injectable()
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.noteRepository, required this.syncService})
    : super(const HomeState()) {
    on<LoadNotes>(_onLoadNotes);
    on<RefreshNotes>(_onRefreshNotes);
    on<DeleteNote>(_onDeleteNote);
    on<SearchChanged>(_onSearchChanged);
    on<TemporarilyRemoveNote>(_onTemporarilyRemoveNote);
    on<RestoreNote>(_onRestoreNote);
    on<GetAiSuggestion>(_onGetAiSuggestion);
    on<ClearAiSuggestion>(_onClearAiSuggestion);
    on<TagFilterChanged>(_onTagFilterChanged);
    on<ClearTagFilter>(_onClearTagFilter);

    // Sync service'i başlat (connectivity değişikliklerini dinlemeye başlar)
    syncService.syncPendingOperations();
  }

  final INoteRepository noteRepository;
  final SyncService syncService;

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
    // Önce manuel sync tetikle
    await syncService.forcSync();

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

  /// Notu geçici olarak kaldır (undo için)
  FutureOr<void> _onTemporarilyRemoveNote(
    TemporarilyRemoveNote event,
    Emitter<HomeState> emit,
  ) async {
    final updatedNotes =
        state.notes.where((note) => note.id != event.noteId).toList();
    emit(state.copyWith(notes: updatedNotes));
  }

  /// Notu geri ekle (undo için)
  FutureOr<void> _onRestoreNote(
    RestoreNote event,
    Emitter<HomeState> emit,
  ) async {
    final updatedNotes = [...state.notes, event.note];
    emit(state.copyWith(notes: updatedNotes));
  }

  /// AI önerisi al
  FutureOr<void> _onGetAiSuggestion(
    GetAiSuggestion event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        aiSuggestionStatus: AiSuggestionStatus.loading,
        aiSuggestionError: '',
      ),
    );

    final result = await noteRepository.getAiSuggestions(event.noteId);

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
  FutureOr<void> _onClearAiSuggestion(
    ClearAiSuggestion event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        aiSuggestionStatus: AiSuggestionStatus.initial,
        aiSuggestionError: '',
      ),
    );
  }

  /// Tag filtresi değişti
  FutureOr<void> _onTagFilterChanged(
    TagFilterChanged event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(selectedTags: event.selectedTags));
  }

  /// Tag filtresini temizle
  FutureOr<void> _onClearTagFilter(
    ClearTagFilter event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(selectedTags: const []));
  }

  /// Notları tarih aralığına göre filtrele
  /// Bugün ve gelecekte aktif olan notları döndür
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
        final startDateOnly = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );

        // Eğer endDate varsa, tarih aralığına göre kontrol et
        if (note.endDate != null && note.endDate!.isNotEmpty) {
          final endDate = DateTime.parse(note.endDate!);
          final endDateOnly = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
          );

          // Not bugün veya gelecekte devam ediyorsa göster
          return endDateOnly.isAtSameMomentAs(today) ||
              endDateOnly.isAfter(today);
        }

        // Sadece startDate varsa, bugün ve gelecek tarihli notları göster
        return startDateOnly.isAtSameMomentAs(today) ||
            startDateOnly.isAfter(today);
      } on FormatException {
        // Tarih parse edilemezse, notu göster
        return true;
      }
    }).toList();
  }
}
