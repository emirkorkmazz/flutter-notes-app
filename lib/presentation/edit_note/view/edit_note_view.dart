import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '../cubit/cubit.dart';

class EditNoteView extends StatefulWidget {
  const EditNoteView({
    required this.noteId,
    required this.initialTitle,
    required this.initialContent,
    super.key,
  });

  final String noteId;
  final String initialTitle;
  final String initialContent;

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);

    // Cubit'i initialize et
    context.read<EditNoteCubit>().initializeNote(
      noteId: widget.noteId,
      title: widget.initialTitle,
      content: widget.initialContent,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notu Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<EditNoteCubit, EditNoteState>(
            builder: (context, state) {
              return TextButton(
                onPressed:
                    state.hasChanges && state.isValid
                        ? () => _resetForm(context)
                        : null,
                child: const Text('Geri Al'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<EditNoteCubit, EditNoteState>(
        listener: (context, state) {
          if (state.status == EditNoteStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Not başarıyla güncellendi!'),
                backgroundColor: Colors.green,
              ),
            );
            // Home sayfasına geri dön
            context.go(AppRouteName.home.path);
          } else if (state.status == EditNoteStatus.failure) {
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
                      context.read<EditNoteCubit>().titleChanged(value);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Başlık gerekli';
                      }
                      return null;
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
                        context.read<EditNoteCubit>().contentChanged(value);
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

                  /// Güncelle butonu
                  AppElevatedButton(
                    onPressed:
                        state.status == EditNoteStatus.loading ||
                                !state.isValid ||
                                !state.hasChanges
                            ? null
                            : () => _updateNote(context, state),
                    child:
                        state.status == EditNoteStatus.loading
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
                              'Güncelle',
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

  /// Notu güncelle
  void _updateNote(BuildContext context, EditNoteState state) {
    if (_formKey.currentState!.validate()) {
      context.read<EditNoteCubit>().updateNote();
    }
  }

  /// Formu orijinal haline geri al
  void _resetForm(BuildContext context) {
    context.read<EditNoteCubit>().resetForm();
    _titleController.text = context.read<EditNoteCubit>().state.title;
    _contentController.text = context.read<EditNoteCubit>().state.content;
  }
}
