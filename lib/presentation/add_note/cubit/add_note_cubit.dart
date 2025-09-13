import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '/core/core.dart';
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

  /// Başlangıç tarihi değiştiğinde
  void startDateChanged(String? startDate) {
    emit(
      state.copyWith(
        startDate: startDate,
        status: AddNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Bitiş tarihi değiştiğinde
  void endDateChanged(String? endDate) {
    emit(
      state.copyWith(
        endDate: endDate,
        status: AddNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Sabitleme durumu değiştiğinde
  void pinnedChanged(bool pinned) {
    emit(
      state.copyWith(
        pinned: pinned,
        status: AddNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Etiket eklendiğinde
  void tagAdded(NoteTag tag) {
    if (!state.tags.contains(tag)) {
      final newTags = [...state.tags, tag];
      emit(
        state.copyWith(
          tags: newTags,
          status: AddNoteStatus.initial,
          errorMessage: '',
        ),
      );
    }
  }

  /// Etiket silindiğinde
  void tagRemoved(NoteTag tag) {
    final newTags = state.tags.where((t) => t != tag).toList();
    emit(
      state.copyWith(
        tags: newTags,
        status: AddNoteStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Notu kaydet
  Future<void> saveNote() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: AddNoteStatus.loading));

    // Debug için tarih değerlerini yazdır
    debugPrint('Start Date: "${state.startDate}"');
    debugPrint('End Date: "${state.endDate}"');
    debugPrint('Start Date isEmpty: ${state.startDate?.isEmpty}');
    debugPrint('End Date isEmpty: ${state.endDate?.isEmpty}');

    final result = await noteRepository.createNote(
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
