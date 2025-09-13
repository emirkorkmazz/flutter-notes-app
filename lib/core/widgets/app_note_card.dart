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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Slidable(
        key: ValueKey(note.id ?? ''),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Sil',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onEdit(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Düzenle',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve menü
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık
                        Expanded(
                          child: Text(
                            note.title?.isNotEmpty ?? false
                                ? note.title!
                                : 'Başlıksız Not',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Menü butonu
                        _buildMenuButton(context),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // İçerik
                    if (note.content?.isNotEmpty ?? false) ...[
                      Text(
                        note.content!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5568),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Alt kısım - Tarih ve etiketler
                    Row(
                      children: [
                        // Tarih
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatNoteDate(note.startDate, note.endDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Pin ikonu (eğer pinlenmişse)
                        if (note.pinned ?? false) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.push_pin,
                                  size: 14,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Sabitli',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Etiketler
                    if (note.tags != null && note.tags!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: note.tags!.map(_buildTagChip).toList(),
                      ),
                    ],
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
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Color(0xFF4A5568)),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
      ),
    );
  }

  /// Etiket chip'i oluştur
  Widget _buildTagChip(NoteTag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTagColor(tag).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getTagColor(tag).withValues(alpha: 0.3)),
      ),
      child: Text(
        tag.displayName,
        style: TextStyle(
          fontSize: 11,
          color: _getTagColor(tag),
          fontWeight: FontWeight.w600,
        ),
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
  String _formatNoteDate(String? startDate, String? endDate) {
    if (startDate == null || startDate.isEmpty) {
      return 'Tarih belirtilmemiş';
    }

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
