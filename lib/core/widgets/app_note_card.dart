import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '/core/core.dart';
import '/data/data.dart';

///
/// Not kartları için özel tasarım widget'ı
class AppNoteCard extends StatelessWidget {
  ///
  const AppNoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.onAiSuggestion,
    super.key,
  });

  /// Not modeli
  final NoteModel note;

  /// Düzenle butonuna basıldığında çağrılan callback
  final VoidCallback onEdit;

  /// Sil butonuna basıldığında çağrılan callback
  final VoidCallback onDelete;

  /// Karta basıldığında çağrılan callback
  final VoidCallback? onTap;

  /// AI önerisi butonuna basıldığında çağrılan callback
  final VoidCallback? onAiSuggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Slidable(
        key: ValueKey(note.id ?? ''),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onDelete(),
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Sil',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              spacing: 8,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onEdit(),
              backgroundColor: const Color(0xFF3182CE),
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'Düzenle',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              spacing: 8,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - Başlık ve menü
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title?.isNotEmpty ?? false
                                    ? note.title!
                                    : 'Başlıksız Not',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A202C),
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Tarih ve pin durumu
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.schedule_rounded,
                                          size: 14,
                                          color: Colors.blue.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatNoteDate(
                                            note.startDate,
                                            note.endDate,
                                            note.createdAt,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (note.pinned ?? false) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.amber.shade400,
                                            Colors.orange.shade400,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.amber.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.push_pin_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Sabitli',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Menü butonu
                        _buildMenuButton(context),
                      ],
                    ),

                    // İçerik
                    if (note.content?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          note.content!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4A5568),
                            height: 1.5,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    // Etiketler
                    if (note.tags != null && note.tags!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: note.tags!.map(_buildTagChip).toList(),
                      ),
                    ],

                    // Footer - Alt çizgi
                    const SizedBox(height: 16),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                            Colors.pink.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Menü butonu oluştur
  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        } else if (value == 'ai_suggestion' && onAiSuggestion != null) {
          onAiSuggestion!();
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Düzenle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onAiSuggestion != null)
              PopupMenuItem(
                value: 'ai_suggestion',
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.pink.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'AI Önerisi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_rounded,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sil',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          size: 20,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  /// Etiket chip'i oluştur
  Widget _buildTagChip(NoteTag tag) {
    final tagColor = _getTagColor(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tagColor.withValues(alpha: 0.1),
            tagColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tagColor.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: tagColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            tag.displayName,
            style: TextStyle(
              fontSize: 12,
              color: tagColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Etiket rengini belirle
  Color _getTagColor(NoteTag tag) {
    switch (tag) {
      case NoteTag.work:
        return const Color(0xFF3B82F6); // Mavi
      case NoteTag.personal:
        return const Color(0xFF10B981); // Yeşil
      case NoteTag.important:
        return const Color(0xFFEF4444); // Kırmızı
      case NoteTag.ideas:
        return const Color(0xFF8B5CF6); // Mor
      case NoteTag.reminder:
        return const Color(0xFFF59E0B); // Turuncu
      case NoteTag.meeting:
        return const Color(0xFF06B6D4); // Cyan
      case NoteTag.study:
        return const Color(0xFF8B5CF6); // Mor
      case NoteTag.shopping:
        return const Color(0xFFEC4899); // Pembe
      case NoteTag.todo:
        return const Color(0xFFF59E0B); // Turuncu
      case NoteTag.finance:
        return const Color(0xFF10B981); // Yeşil
      case NoteTag.health:
        return const Color(0xFFEF4444); // Kırmızı
      case NoteTag.travel:
        return const Color(0xFF06B6D4); // Cyan
    }
  }

  /// Not tarihlerini formatla
  String _formatNoteDate(
    String? startDate,
    String? endDate,
    String? createdAt,
  ) {
    // Eğer startDate varsa, not tarihini göster
    if (startDate != null && startDate.isNotEmpty) {
      try {
        final start = DateTime.parse(startDate);
        final startFormatted = _formatDate(start);

        if (endDate != null && endDate.isNotEmpty) {
          final end = DateTime.parse(endDate);
          final endFormatted = _formatDate(end);

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
        return _formatDate(created);
      } on FormatException {
        return 'Tarih belirtilmemiş';
      }
    }

    return 'Tarih belirtilmemiş';
  }

  /// Tarihi Türkçe formatta göster
  String _formatDate(DateTime date) {
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
}
