import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '../cubit/cubit.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({super.key});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında form'u temizle
    _resetForm();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Not'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.imBackgroundFirst.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocConsumer<AddNoteCubit, AddNoteState>(
          listener: (context, state) {
            if (state.status == AddNoteStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Not başarıyla kaydedildi!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Form'u resetle
              _resetForm();
              // Home sayfasına geri dön
              context.go(AppRouteName.home.path);
            } else if (state.status == AddNoteStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Başlık alanı
                      AppTextField(
                        controller: _titleController,
                        hintText: 'Not başlığı',
                        prefix: const Icon(Icons.title),
                        onChanged: (value) {
                          context.read<AddNoteCubit>().titleChanged(value);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Başlık gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      /// Tarih alanları
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateSelector(
                              context: context,
                              controller: _startDateController,
                              label: 'Başlangıç Tarihi',
                              icon: Icons.calendar_today,
                              onTap: () => _selectStartDate(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDateSelector(
                              context: context,
                              controller: _endDateController,
                              label: 'Bitiş Tarihi',
                              icon: Icons.event,
                              onTap: () => _selectEndDate(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// Sabitleme switch'i
                      BlocBuilder<AddNoteCubit, AddNoteState>(
                        builder: (context, state) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: SwitchListTile(
                              title: const Text(
                                'Notu Sabitle',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: const Text(
                                'Bu notu listenin üstünde göster',
                                style: TextStyle(color: Colors.white70),
                              ),
                              value: state.pinned,
                              onChanged: (value) {
                                context.read<AddNoteCubit>().pinnedChanged(
                                  value,
                                );
                              },
                              secondary: const Icon(
                                Icons.push_pin,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      /// Tag seçimi
                      BlocBuilder<AddNoteCubit, AddNoteState>(
                        builder: (context, state) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Etiketler',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (state.tags.isNotEmpty) ...[
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          state.tags
                                              .map(
                                                (tag) => Chip(
                                                  label: Text(tag.displayName),
                                                  onDeleted: () {
                                                    context
                                                        .read<AddNoteCubit>()
                                                        .tagRemoved(tag);
                                                  },
                                                  deleteIcon: const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  ElevatedButton.icon(
                                    onPressed: () => _showTagSelector(context),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Etiket Ekle'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      /// İçerik alanı
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        child: AppTextField(
                          controller: _contentController,
                          hintText: 'Not içeriği...',
                          prefix: const Icon(Icons.description),
                          onChanged: (value) {
                            context.read<AddNoteCubit>().contentChanged(value);
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'İçerik gerekli';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Kaydet butonu
                      AppElevatedButton(
                        onPressed:
                            state.status == AddNoteStatus.loading ||
                                    !state.isValid
                                ? null
                                : () => _saveNote(context, state),
                        child:
                            state.status == AddNoteStatus.loading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Kaydet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 32), // Ekstra boşluk
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Notu kaydet
  void _saveNote(BuildContext context, AddNoteState state) {
    if (_formKey.currentState!.validate()) {
      context.read<AddNoteCubit>().saveNote();
    }
  }

  /// Başlangıç tarihi seç
  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      debugPrint('Start Date Selected: "$formattedDate"');
      _startDateController.text = formattedDate;
      context.read<AddNoteCubit>().startDateChanged(formattedDate);
    } else {
      // Tarih seçilmediğinde null gönder
      debugPrint('Start Date Not Selected');
      _startDateController.clear();
      context.read<AddNoteCubit>().startDateChanged(null);
    }
  }

  /// Bitiş tarihi seç
  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      print('End Date Selected: "$formattedDate"');
      _endDateController.text = formattedDate;
      context.read<AddNoteCubit>().endDateChanged(formattedDate);
    } else {
      // Tarih seçilmediğinde null gönder
      print('End Date Not Selected');
      _endDateController.clear();
      context.read<AddNoteCubit>().endDateChanged(null);
    }
  }

  /// Tag seçici göster
  void _showTagSelector(BuildContext context) {
    final currentTags = context.read<AddNoteCubit>().state.tags;
    final availableTags =
        NoteTag.values.where((tag) => !currentTags.contains(tag)).toList();

    showModalBottomSheet<void>(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Etiket Seç',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (availableTags.isEmpty)
                  const Text('Tüm etiketler zaten eklenmiş')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        availableTags
                            .map(
                              (tag) => ActionChip(
                                label: Text(tag.displayName),
                                onPressed: () {
                                  context.read<AddNoteCubit>().tagAdded(tag);
                                  Navigator.of(context).pop();
                                },
                              ),
                            )
                            .toList(),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kapat'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  /// Tarih seçici widget'ı oluştur
  Widget _buildDateSelector({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.text.isEmpty ? 'Tarih seçin' : controller.text,
                    style: TextStyle(
                      color:
                          controller.text.isEmpty
                              ? Colors.white54
                              : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  /// Form'u sıfırla
  void _resetForm() {
    _titleController.clear();
    _contentController.clear();
    _startDateController.clear();
    _endDateController.clear();
    context.read<AddNoteCubit>().reset();
  }
}
