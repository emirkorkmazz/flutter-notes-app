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
    this.startDate,
    this.endDate,
    this.pinned = false,
    this.tags = const [],
    this.isValid = false,
    this.errorMessage = '',
  });

  /// Durum
  final AddNoteStatus status;

  /// Not başlığı
  final String title;

  /// Not içeriği
  final String content;

  /// Başlangıç tarihi
  final String? startDate;

  /// Bitiş tarihi
  final String? endDate;

  /// Sabitlenmiş mi
  final bool pinned;

  /// Etiketler
  final List<NoteTag> tags;

  /// Form validasyonu
  final bool isValid;

  /// Hata mesajı
  final String errorMessage;

  AddNoteState copyWith({
    AddNoteStatus? status,
    String? title,
    String? content,
    String? startDate,
    String? endDate,
    bool? pinned,
    List<NoteTag>? tags,
    bool? isValid,
    String? errorMessage,
  }) {
    return AddNoteState(
      status: status ?? this.status,
      title: title ?? this.title,
      content: content ?? this.content,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pinned: pinned ?? this.pinned,
      tags: tags ?? this.tags,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    title,
    content,
    startDate,
    endDate,
    pinned,
    tags,
    isValid,
    errorMessage,
  ];
}
