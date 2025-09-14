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

/// Notu geçici olarak kaldır event'i (undo için)
final class TemporarilyRemoveNote extends HomeEvent {
  const TemporarilyRemoveNote(this.noteId);

  final String noteId;

  @override
  List<Object> get props => [noteId];
}

/// Notu geri ekle event'i (undo için)
final class RestoreNote extends HomeEvent {
  const RestoreNote(this.note);

  final NoteModel note;

  @override
  List<Object> get props => [note];
}

/// AI önerisi al event'i
final class GetAiSuggestion extends HomeEvent {
  const GetAiSuggestion(this.noteId);

  final String noteId;

  @override
  List<Object> get props => [noteId];
}

/// AI önerisi state'ini temizle event'i
final class ClearAiSuggestion extends HomeEvent {
  const ClearAiSuggestion();
}

/// Tag filtresi değişti event'i
final class TagFilterChanged extends HomeEvent {
  const TagFilterChanged(this.selectedTags);

  final List<NoteTag> selectedTags;

  @override
  List<Object> get props => [selectedTags];
}

/// Tag filtresini temizle event'i
final class ClearTagFilter extends HomeEvent {
  const ClearTagFilter();
}
