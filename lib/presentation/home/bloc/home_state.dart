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
  });

  /// Durum
  final HomeStatus status;

  /// Not listesi
  final List<GetNotesResponse> notes;

  /// Hata mesajı
  final String errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<GetNotesResponse>? notes,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage];
}
