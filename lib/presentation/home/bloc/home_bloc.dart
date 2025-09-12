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
        emit(
          state.copyWith(
            status: HomeStatus.success,
            notes: response.data ?? [],
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
        emit(
          state.copyWith(
            status: HomeStatus.success,
            notes: response.data ?? [],
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
}
