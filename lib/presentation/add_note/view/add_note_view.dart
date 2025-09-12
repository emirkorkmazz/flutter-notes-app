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
      ),
      body: BlocConsumer<AddNoteCubit, AddNoteState>(
        listener: (context, state) {
          if (state.status == AddNoteStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Not başarıyla kaydedildi!'),
                backgroundColor: Colors.green,
              ),
            );
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
          return Padding(
            padding: const EdgeInsets.all(16),
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
                        child: AppTextField(
                          controller: _startDateController,
                          hintText: 'Başlangıç tarihi',
                          prefix: const Icon(Icons.calendar_today),
                          readOnly: true,
                          onTap: () => _selectStartDate(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _endDateController,
                          hintText: 'Bitiş tarihi',
                          prefix: const Icon(Icons.event),
                          readOnly: true,
                          onTap: () => _selectEndDate(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Sabitleme switch'i
                  BlocBuilder<AddNoteCubit, AddNoteState>(
                    builder: (context, state) {
                      return Card(
                        child: SwitchListTile(
                          title: const Text('Notu Sabitle'),
                          subtitle: const Text(
                            'Bu notu listenin üstünde göster',
                          ),
                          value: state.pinned,
                          onChanged: (value) {
                            context.read<AddNoteCubit>().pinnedChanged(value);
                          },
                          secondary: const Icon(Icons.push_pin),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Tag seçimi
                  BlocBuilder<AddNoteCubit, AddNoteState>(
                    builder: (context, state) {
                      return Card(
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
                                  backgroundColor: Colors.blue.shade100,
                                  foregroundColor: Colors.blue.shade800,
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
                  Expanded(
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
                        state.status == AddNoteStatus.loading || !state.isValid
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
                ],
              ),
            ),
          );
        },
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _startDateController.text = formattedDate;
      context.read<AddNoteCubit>().startDateChanged(formattedDate);
    }
  }

  /// Bitiş tarihi seç
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _endDateController.text = formattedDate;
      context.read<AddNoteCubit>().endDateChanged(formattedDate);
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
}
