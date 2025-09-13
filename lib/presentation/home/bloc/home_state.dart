part of 'home_bloc.dart';

enum HomeStatus {
  initial, // Başlangıç durumu
  loading, // Notlar yükleniyor
  success, // Notlar başarıyla yüklendi
  failure, // Notlar yüklenirken hata oluştu
}

final class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.notes = const [],
    this.errorMessage = '',
    this.searchTerm = '',
    this.aiSuggestionStatus = AiSuggestionStatus.initial,
    this.aiSuggestion,
    this.aiSuggestionError = '',
  });

  /// Durum
  final HomeStatus status;

  /// Not listesi
  final List<NoteModel> notes;

  /// Hata mesajı
  final String errorMessage;

  /// Arama terimi
  final String searchTerm;

  /// AI önerisi durumu
  final AiSuggestionStatus aiSuggestionStatus;

  /// AI önerisi verisi
  final GetAiSuggestionData? aiSuggestion;

  /// AI önerisi hata mesajı
  final String aiSuggestionError;

  HomeState copyWith({
    HomeStatus? status,
    List<NoteModel>? notes,
    String? errorMessage,
    String? searchTerm,
    AiSuggestionStatus? aiSuggestionStatus,
    GetAiSuggestionData? aiSuggestion,
    String? aiSuggestionError,
  }) {
    return HomeState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
      aiSuggestionStatus: aiSuggestionStatus ?? this.aiSuggestionStatus,
      aiSuggestion: aiSuggestion ?? this.aiSuggestion,
      aiSuggestionError: aiSuggestionError ?? this.aiSuggestionError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notes,
    errorMessage,
    searchTerm,
    aiSuggestionStatus,
    aiSuggestion,
    aiSuggestionError,
  ];
}
