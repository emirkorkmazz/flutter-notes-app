import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/core/core.dart';
import '/domain/domain.dart';

part 'edit_note_state.dart';

@Injectable()
class EditNoteCubit extends Cubit<EditNoteState> {
  EditNoteCubit({required this.noteRepository, required this.syncService})
    : super(const EditNoteState());

  final INoteRepository noteRepository;
  final SyncService syncService;

  /// Not bilgilerini initialize et
  void initializeNote({
    required String noteId,
    required String title,
    required String content,
    String? startDate,
    String? endDate,
    bool pinned = false,
    List<NoteTag> tags = const [],
  }) {
    emit(
      state.copyWith(
        noteId: noteId,
        title: title,
        content: content,
        startDate: startDate,
        endDate: endDate,
        pinned: pinned,
        tags: tags,
        originalTitle: title,
        originalContent: content,
        originalStartDate: startDate,
        originalEndDate: endDate,
        originalPinned: pinned,
        originalTags: tags,
        isValid: _isFormValid(title, content),
        hasChanges: false,
        status: EditNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Başlık değiştiğinde
  void titleChanged(String title) {
    final hasChanges = _hasChanges(
      title,
      state.content,
      state.startDate,
      state.endDate,
      state.pinned,
      state.tags,
    );
    emit(
      state.copyWith(
        title: title,
        isValid: _isFormValid(title, state.content),
        hasChanges: hasChanges,
        status: EditNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// İçerik değiştiğinde
  void contentChanged(String content) {
    final hasChanges = _hasChanges(
      state.title,
      content,
      state.startDate,
      state.endDate,
      state.pinned,
      state.tags,
    );
    emit(
      state.copyWith(
        content: content,
        isValid: _isFormValid(state.title, content),
        hasChanges: hasChanges,
        status: EditNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Başlangıç tarihi değiştiğinde
  void startDateChanged(String? startDate) {
    final hasChanges = _hasChanges(
      state.title,
      state.content,
      startDate,
      state.endDate,
      state.pinned,
      state.tags,
    );
    emit(
      state.copyWith(
        startDate: startDate,
        hasChanges: hasChanges,
        status: EditNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Bitiş tarihi değiştiğinde
  void endDateChanged(String? endDate) {
    final hasChanges = _hasChanges(
      state.title,
      state.content,
      state.startDate,
      endDate,
      state.pinned,
      state.tags,
    );
    emit(
      state.copyWith(
        endDate: endDate,
        hasChanges: hasChanges,
        status: EditNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Sabitleme durumu değiştiğinde
  void pinnedChanged(bool pinned) {
    final hasChanges = _hasChanges(
      state.title,
      state.content,
      state.startDate,
      state.endDate,
      pinned,
      state.tags,
    );
    emit(
      state.copyWith(
        pinned: pinned,
        hasChanges: hasChanges,
        status: EditNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Etiket eklendiğinde
  void tagAdded(NoteTag tag) {
    if (!state.tags.contains(tag)) {
      final newTags = [...state.tags, tag];
      final hasChanges = _hasChanges(
        state.title,
        state.content,
        state.startDate,
        state.endDate,
        state.pinned,
        newTags,
      );
      emit(
        state.copyWith(
          tags: newTags,
          hasChanges: hasChanges,
          status: EditNoteStatus.initial,
          errorMessage: '',
        ),
      );
    }
  }

  /// Etiket silindiğinde
  void tagRemoved(NoteTag tag) {
    final newTags = state.tags.where((t) => t != tag).toList();
    final hasChanges = _hasChanges(
      state.title,
      state.content,
      state.startDate,
      state.endDate,
      state.pinned,
      newTags,
    );
    emit(
      state.copyWith(
        tags: newTags,
        hasChanges: hasChanges,
        status: EditNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Notu güncelle
  Future<void> updateNote() async {
    if (!state.isValid || !state.hasChanges) return;

    emit(state.copyWith(status: EditNoteStatus.loading));

    final result = await noteRepository.updateNote(
      id: state.noteId,
      title: state.title.trim(),
      content: state.content.trim(),
      startDate: state.startDate,
      endDate: state.endDate,
      pinned: state.pinned,
      tags: state.tags,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: EditNoteStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (updateNoteResponse) {
        // Güncelleme başarılı, orijinal değerleri güncelle
        emit(
          state.copyWith(
            status: EditNoteStatus.success,
            originalTitle: state.title,
            originalContent: state.content,
            originalStartDate: state.startDate,
            originalEndDate: state.endDate,
            originalPinned: state.pinned,
            originalTags: state.tags,
            hasChanges: false,
          ),
        );
        // Not güncellendikten sonra sync tetikle
        syncService.syncPendingOperations();
      },
    );
  }

  /// Form reset (orijinal değerlere dön)
  void resetForm() {
    emit(
      state.copyWith(
        title: state.originalTitle,
        content: state.originalContent,
        startDate: state.originalStartDate,
        endDate: state.originalEndDate,
        pinned: state.originalPinned,
        tags: state.originalTags,
        isValid: _isFormValid(state.originalTitle, state.originalContent),
        hasChanges: false,
        status: EditNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Form validasyonu kontrolü
  bool _isFormValid(String title, String content) {
    return title.trim().isNotEmpty && content.trim().isNotEmpty;
  }

  /// Değişiklik kontrolü
  bool _hasChanges(
    String title,
    String content,
    String? startDate,
    String? endDate,
    bool pinned,
    List<NoteTag> tags,
  ) {
    return title.trim() != state.originalTitle.trim() ||
        content.trim() != state.originalContent.trim() ||
        startDate != state.originalStartDate ||
        endDate != state.originalEndDate ||
        pinned != state.originalPinned ||
        !_listEquals(tags, state.originalTags);
  }

  /// List karşılaştırması
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
