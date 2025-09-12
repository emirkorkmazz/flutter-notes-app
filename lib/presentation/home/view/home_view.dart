import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '/data/data.dart';
import '../bloc/bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında notları yükle
    context.read<HomeBloc>().add(const LoadNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlarım'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HomeBloc>().add(const RefreshNotes());
            },
          ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.status == HomeStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == HomeStatus.success) {
            if (state.notes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Henüz not yok',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'İlk notunuzu eklemek için + butonuna basın',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshNotes());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        note.title ?? 'Başlıksız Not',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            note.content ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Oluşturulma: ${note.createdAt ?? 'Bilinmiyor'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit' && note.id != null) {
                            _navigateToEditNote(context, note);
                          } else if (value == 'delete' && note.id != null) {
                            _showDeleteDialog(context, note.id!);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Düzenle'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Sil'),
                              ),
                            ],
                      ),
                      onTap: () {
                        // Not detay sayfasına git
                        // context.go('/note/${note.id}');
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Bir hata oluştu'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Not ekleme sayfasına git
          context.go(AppRouteName.addNote.path);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Edit Note sayfasına yönlendir
  void _navigateToEditNote(BuildContext context, GetNotesResponse note) {
    final editPath = AppRouteName.editNote.path.replaceAll(
      ':noteId',
      note.id ?? '',
    );
    context.go(
      '$editPath?title=${Uri.encodeComponent(note.title ?? '')}&content=${Uri.encodeComponent(note.content ?? '')}',
    );
  }

  void _showDeleteDialog(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Notu Sil'),
            content: const Text('Bu notu silmek istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<HomeBloc>().add(DeleteNote(noteId));
                },
                child: const Text('Sil'),
              ),
            ],
          ),
    );
  }
}
