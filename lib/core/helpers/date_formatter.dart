import 'package:flutter/material.dart';

/// Tarih formatlaması için yardımcı sınıf
class DateFormatter {
  DateFormatter._();

  /// DD/MM/YYYY formatından DateTime'a çevirme
  static DateTime? parseFromDisplayFormat(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Geçerli tarih aralığını kontrol et
      if (month < 1 || month > 12 || day < 1 || day > 31) {
        return null;
      }

      return DateTime(year, month, day);
    } on FormatException catch (e) {
      debugPrint('Tarih parse hatası: $e');
      return null;
    }
  }

  /// DateTime'ı DD/MM/YYYY formatına çevirme
  static String formatToDisplayFormat(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// DateTime'ı ISO formatına çevirme (API için)
  static String formatToIsoFormat(DateTime date) {
    return date.toIso8601String();
  }

  /// ISO formatından DateTime'a çevirme
  static DateTime? parseFromIsoFormat(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;

    try {
      return DateTime.parse(isoString);
    } on FormatException catch (e) {
      debugPrint('ISO tarih parse hatası: $e');
      return null;
    }
  }

  /// DateTime'ı Türkçe formatta gösterme (örn: "15 Mart 2024", "Bugün", "Dün")
  static String formatToTurkishDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Bugün, dün, yarın kontrolü
    if (dateOnly.isAtSameMomentAs(today)) {
      return 'Bugün';
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      return 'Dün';
    } else if (dateOnly.isAtSameMomentAs(tomorrow)) {
      return 'Yarın';
    }

    // Ay isimleri
    const monthNames = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    final day = date.day;
    final month = monthNames[date.month];
    final year = date.year;

    // Bu yıl ise yılı gösterme
    if (year == now.year) {
      return '$day $month';
    }

    return '$day $month $year';
  }

  /// Tarih aralığını formatla (başlangıç-bitiş)
  static String formatDateRange(
    String? startDate,
    String? endDate,
    String? createdAt,
  ) {
    // Eğer startDate varsa, not tarihini göster
    if (startDate != null && startDate.isNotEmpty) {
      try {
        final start = DateTime.parse(startDate);
        final startFormatted = formatToTurkishDisplay(start);

        if (endDate != null && endDate.isNotEmpty) {
          final end = DateTime.parse(endDate);
          final endFormatted = formatToTurkishDisplay(end);

          // Eğer başlangıç ve bitiş tarihi aynıysa tek tarih göster
          if (startFormatted == endFormatted) {
            return startFormatted;
          }

          return '$startFormatted - $endFormatted';
        }

        return startFormatted;
      } on FormatException {
        return 'Tarih belirtilmemiş';
      }
    }

    // startDate yoksa, oluşturulma tarihini göster (internet yokken eklenen notlar için)
    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final created = DateTime.parse(createdAt);
        return formatToTurkishDisplay(created);
      } on FormatException {
        return 'Tarih belirtilmemiş';
      }
    }

    return 'Tarih belirtilmemiş';
  }
}
