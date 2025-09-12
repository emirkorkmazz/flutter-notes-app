part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

/// Notları yükle event'i
final class LoadNotes extends HomeEvent {
  const LoadNotes();
}

/// Notları yenile event'i (pull to refresh)
final class RefreshNotes extends HomeEvent {
  const RefreshNotes();
}

/// Not sil event'i
final class DeleteNote extends HomeEvent {
  const DeleteNote(this.noteId);

  final String noteId;

  @override
  List<Object> get props => [noteId];
}

final class SearchChanged extends HomeEvent {
  const SearchChanged(this.searchTerm);

  final String searchTerm;

  @override
  List<Object> get props => [searchTerm];
}
