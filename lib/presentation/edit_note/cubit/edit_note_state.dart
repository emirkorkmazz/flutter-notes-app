part of 'edit_note_cubit.dart';

enum EditNoteStatus {
  initial, // Başlangıç durumu
  loading, // Not güncelleniyor
  success, // Not başarıyla güncellendi
  failure, // Not güncellenirken hata oluştu
}

final class EditNoteState extends Equatable {
  const EditNoteState({
    this.status = EditNoteStatus.initial,
    this.noteId = '',
    this.title = '',
    this.content = '',
    this.originalTitle = '',
    this.originalContent = '',
    this.isValid = false,
    this.hasChanges = false,
    this.errorMessage = '',
  });

  /// Durum
  final EditNoteStatus status;

  /// Not ID'si
  final String noteId;

  /// Not başlığı
  final String title;

  /// Not içeriği
  final String content;

  /// Orijinal başlık (değişiklik kontrolü için)
  final String originalTitle;

  /// Orijinal içerik (değişiklik kontrolü için)
  final String originalContent;

  /// Form validasyonu
  final bool isValid;

  /// Değişiklik var mı
  final bool hasChanges;

  /// Hata mesajı
  final String errorMessage;

  EditNoteState copyWith({
    EditNoteStatus? status,
    String? noteId,
    String? title,
    String? content,
    String? originalTitle,
    String? originalContent,
    bool? isValid,
    bool? hasChanges,
    String? errorMessage,
  }) {
    return EditNoteState(
      status: status ?? this.status,
      noteId: noteId ?? this.noteId,
      title: title ?? this.title,
      content: content ?? this.content,
      originalTitle: originalTitle ?? this.originalTitle,
      originalContent: originalContent ?? this.originalContent,
      isValid: isValid ?? this.isValid,
      hasChanges: hasChanges ?? this.hasChanges,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    noteId,
    title,
    content,
    originalTitle,
    originalContent,
    isValid,
    hasChanges,
    errorMessage,
  ];
}
