part of 'all_notes_cubit.dart';

enum AllNotesStatus {
  initial, // Başlangıç durumu
  loading, // Notlar yükleniyor
  success, // Notlar başarıyla yüklendi
  failure, // Notlar yüklenirken hata oluştu
}

final class AllNotesState extends Equatable {
  const AllNotesState({
    this.status = AllNotesStatus.initial,
    this.notes = const [],
    this.errorMessage = '',
    this.searchTerm = '',
  });

  /// Durum
  final AllNotesStatus status;

  /// Not listesi
  final List<NoteModel> notes;

  /// Hata mesajı
  final String errorMessage;

  /// Arama terimi
  final String searchTerm;

  AllNotesState copyWith({
    AllNotesStatus? status,
    List<NoteModel>? notes,
    String? errorMessage,
    String? searchTerm,
  }) {
    return AllNotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage, searchTerm];
}
