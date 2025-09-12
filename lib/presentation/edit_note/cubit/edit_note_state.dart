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
    this.startDate,
    this.endDate,
    this.pinned = false,
    this.tags = const [],
    this.originalTitle = '',
    this.originalContent = '',
    this.originalStartDate,
    this.originalEndDate,
    this.originalPinned = false,
    this.originalTags = const [],
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

  /// Başlangıç tarihi
  final String? startDate;

  /// Bitiş tarihi
  final String? endDate;

  /// Sabitlenmiş mi
  final bool pinned;

  /// Etiketler
  final List<NoteTag> tags;

  /// Orijinal başlık (değişiklik kontrolü için)
  final String originalTitle;

  /// Orijinal içerik (değişiklik kontrolü için)
  final String originalContent;

  /// Orijinal başlangıç tarihi
  final String? originalStartDate;

  /// Orijinal bitiş tarihi
  final String? originalEndDate;

  /// Orijinal sabitleme durumu
  final bool originalPinned;

  /// Orijinal etiketler
  final List<NoteTag> originalTags;

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
    String? startDate,
    String? endDate,
    bool? pinned,
    List<NoteTag>? tags,
    String? originalTitle,
    String? originalContent,
    String? originalStartDate,
    String? originalEndDate,
    bool? originalPinned,
    List<NoteTag>? originalTags,
    bool? isValid,
    bool? hasChanges,
    String? errorMessage,
  }) {
    return EditNoteState(
      status: status ?? this.status,
      noteId: noteId ?? this.noteId,
      title: title ?? this.title,
      content: content ?? this.content,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pinned: pinned ?? this.pinned,
      tags: tags ?? this.tags,
      originalTitle: originalTitle ?? this.originalTitle,
      originalContent: originalContent ?? this.originalContent,
      originalStartDate: originalStartDate ?? this.originalStartDate,
      originalEndDate: originalEndDate ?? this.originalEndDate,
      originalPinned: originalPinned ?? this.originalPinned,
      originalTags: originalTags ?? this.originalTags,
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
    startDate,
    endDate,
    pinned,
    tags,
    originalTitle,
    originalContent,
    originalStartDate,
    originalEndDate,
    originalPinned,
    originalTags,
    isValid,
    hasChanges,
    errorMessage,
  ];
}
