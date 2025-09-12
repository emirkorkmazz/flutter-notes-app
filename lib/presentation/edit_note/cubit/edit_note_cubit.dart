import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/domain/domain.dart';

part 'edit_note_state.dart';

@Injectable()
class EditNoteCubit extends Cubit<EditNoteState> {
  EditNoteCubit({required this.noteRepository}) : super(const EditNoteState());

  final INoteRepository noteRepository;

  /// Not bilgilerini initialize et
  void initializeNote({
    required String noteId,
    required String title,
    required String content,
  }) {
    emit(
      state.copyWith(
        noteId: noteId,
        title: title,
        content: content,
        originalTitle: title,
        originalContent: content,
        isValid: _isFormValid(title, content),
        hasChanges: false,
        status: EditNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Başlık değiştiğinde
  void titleChanged(String title) {
    final hasChanges = _hasChanges(title, state.content);
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
    final hasChanges = _hasChanges(state.title, content);
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

  /// Notu güncelle
  Future<void> updateNote() async {
    if (!state.isValid || !state.hasChanges) return;

    emit(state.copyWith(status: EditNoteStatus.loading));

    final result = await noteRepository.updateNote(
      id: state.noteId,
      title: state.title.trim(),
      content: state.content.trim(),
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
            hasChanges: false,
          ),
        );
      },
    );
  }

  /// Form reset (orijinal değerlere dön)
  void resetForm() {
    emit(
      state.copyWith(
        title: state.originalTitle,
        content: state.originalContent,
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
  bool _hasChanges(String title, String content) {
    return title.trim() != state.originalTitle.trim() ||
        content.trim() != state.originalContent.trim();
  }
}
