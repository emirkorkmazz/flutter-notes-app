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
}
