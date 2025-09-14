enum NoteTag {
  personal,
  work,
  meeting,
  study,
  shopping,
  todo,
  finance,
  health,
  travel,
  ideas,
  reminder,
  important,
}

extension NoteTagExtension on NoteTag {
  /// API'ye gönderilecek string değeri
  String get apiValue {
    switch (this) {
      case NoteTag.personal:
        return 'personal';
      case NoteTag.work:
        return 'work';
      case NoteTag.meeting:
        return 'meeting';
      case NoteTag.study:
        return 'study';
      case NoteTag.shopping:
        return 'shopping';
      case NoteTag.todo:
        return 'todo';
      case NoteTag.finance:
        return 'finance';
      case NoteTag.health:
        return 'health';
      case NoteTag.travel:
        return 'travel';
      case NoteTag.ideas:
        return 'ideas';
      case NoteTag.reminder:
        return 'reminder';
      case NoteTag.important:
        return 'important';
    }
  }

  /// UI'da gösterilecek Türkçe metin
  String get displayName {
    switch (this) {
      case NoteTag.personal:
        return 'Kişisel';
      case NoteTag.work:
        return 'İş';
      case NoteTag.meeting:
        return 'Toplantı';
      case NoteTag.study:
        return 'Çalışma';
      case NoteTag.shopping:
        return 'Alışveriş';
      case NoteTag.todo:
        return 'Yapılacaklar';
      case NoteTag.finance:
        return 'Finans';
      case NoteTag.health:
        return 'Sağlık';
      case NoteTag.travel:
        return 'Seyahat';
      case NoteTag.ideas:
        return 'Fikirler';
      case NoteTag.reminder:
        return 'Hatırlatıcı';
      case NoteTag.important:
        return 'Önemli';
    }
  }

  /// API'den gelen string değerini NoteTag enum'una çevir
  static NoteTag? fromApiValue(String? value) {
    if (value == null) return null;

    for (final tag in NoteTag.values) {
      if (tag.apiValue == value) {
        return tag;
      }
    }
    return null;
  }

  /// String listesini NoteTag listesine çevir
  static List<NoteTag> fromApiValues(List<String>? values) {
    if (values == null) return [];

    return values
        .map(fromApiValue)
        .where((tag) => tag != null)
        .cast<NoteTag>()
        .toList();
  }

  /// NoteTag listesini API'ye gönderilecek string listesine çevir
  static List<String> toApiValues(List<NoteTag> tags) {
    return tags.map((tag) => tag.apiValue).toList();
  }
}
