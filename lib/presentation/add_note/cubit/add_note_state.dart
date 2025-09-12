part of 'add_note_cubit.dart';

enum AddNoteStatus {
  initial, // Başlangıç durumu
  loading, // Not kaydediliyor
  success, // Not başarıyla kaydedildi
  failure, // Not kaydedilirken hata oluştu
}

final class AddNoteState extends Equatable {
  const AddNoteState({
    this.status = AddNoteStatus.initial,
    this.title = '',
    this.content = '',
    this.isValid = false,
    this.errorMessage = '',
  });

  /// Durum
  final AddNoteStatus status;

  /// Not başlığı
  final String title;

  /// Not içeriği
  final String content;

  /// Form validasyonu
  final bool isValid;

  /// Hata mesajı
  final String errorMessage;

  AddNoteState copyWith({
    AddNoteStatus? status,
    String? title,
    String? content,
    bool? isValid,
    String? errorMessage,
  }) {
    return AddNoteState(
      status: status ?? this.status,
      title: title ?? this.title,
      content: content ?? this.content,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, title, content, isValid, errorMessage];
}
