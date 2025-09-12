import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/domain/domain.dart';

part 'add_note_state.dart';

@Injectable()
class AddNoteCubit extends Cubit<AddNoteState> {
  AddNoteCubit({required this.noteRepository}) : super(const AddNoteState());

  final INoteRepository noteRepository;

  /// Başlık değiştiğinde
  void titleChanged(String title) {
    emit(
      state.copyWith(
        title: title,
        isValid: _isFormValid(title, state.content),
        status: AddNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// İçerik değiştiğinde
  void contentChanged(String content) {
    emit(
      state.copyWith(
        content: content,
        isValid: _isFormValid(state.title, content),
        status: AddNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Notu kaydet
  Future<void> saveNote() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: AddNoteStatus.loading));

    final result = await noteRepository.createNote(
      title: state.title.trim(),
      content: state.content.trim(),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AddNoteStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (createNoteResponse) {
        emit(state.copyWith(status: AddNoteStatus.success));
      },
    );
  }

  /// Form reset
  void reset() {
    emit(const AddNoteState());
  }

  /// Form validasyonu kontrolü
  bool _isFormValid(String title, String content) {
    return title.trim().isNotEmpty && content.trim().isNotEmpty;
  }
}
