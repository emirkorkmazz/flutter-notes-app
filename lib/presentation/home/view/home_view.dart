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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında notları yükle
    context.read<HomeBloc>().add(const LoadNotes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.imBackgroundFirst.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 80, // Bottom bar yüksekliği kadar
          ),
          child: BlocConsumer<HomeBloc, HomeState>(
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
              return Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildNotesContent(state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Üst kısım - Logo ve + butonu
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Image.asset(Assets.icons.icAppLogo.path, height: 70, width: 70),

          const Spacer(),

          const Text(
            'Ana Sayfa',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const Spacer(),
          // + Butonu
          FloatingActionButton(
            onPressed: () {
              context.push(AppRouteName.addNote.path);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  /// Arama inputu
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<HomeBloc>().add(SearchChanged(value));
        },
        decoration: InputDecoration(
          hintText: 'Notlarda ara...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Not içeriği - Pinlenmiş ve normal notlar
  Widget _buildNotesContent(HomeState state) {
    if (state.status == HomeStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HomeStatus.success) {
      // Arama terimine göre notları filtrele
      final filteredNotes = _filterNotes(state.notes, state.searchTerm);
      final pinnedNotes =
          filteredNotes.where((note) => note.pinned ?? false).toList();
      final regularNotes =
          filteredNotes.where((note) => note.pinned != true).toList();

      if (filteredNotes.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const RefreshNotes());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildEmptyState(state.searchTerm.isNotEmpty),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(const RefreshNotes());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pinlenmiş notlar bölümü
              if (pinnedNotes.isNotEmpty) ...[
                _buildSectionTitle('Sabitlenmiş'),
                const SizedBox(height: 8),
                _buildNotesList(pinnedNotes),
                const SizedBox(height: 24),
              ],

              // Normal notlar bölümü
              if (regularNotes.isNotEmpty) ...[
                _buildSectionTitle('Günlük Aktif Notlar'),
                const SizedBox(height: 8),
                _buildNotesList(regularNotes),
              ],
            ],
          ),
        ),
      );
    }

    return const Center(child: Text('Bir hata oluştu'));
  }

  /// Bölüm başlığı
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyState(bool isSearching) {
    if (isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Arama sonucu bulunamadı',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Farklı bir arama terimi deneyin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Henüz not yok',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'İlk notunuzu eklemek için + butonuna basın',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Notları filtrele
  List<NoteModel> _filterNotes(List<NoteModel> notes, String searchTerm) {
    if (searchTerm.isEmpty) return notes;

    final searchTermLower = searchTerm.toLowerCase();
    return notes.where((note) {
      final title = (note.title ?? '').toLowerCase();
      final content = (note.content ?? '').toLowerCase();
      return title.contains(searchTermLower) ||
          content.contains(searchTermLower);
    }).toList();
  }

  /// Not listesini oluştur
  Widget _buildNotesList(List<NoteModel> notes) {
    return Column(children: notes.map(_buildNoteCard).toList());
  }

  /// Tek bir not kartı oluştur
  Widget _buildNoteCard(NoteModel note) {
    return AppNoteCard(
      note: note,
      onEdit: () {
        if (note.id != null) {
          _navigateToEditNote(context, note);
        }
      },
      onDelete: () {
        if (note.id != null) {
          _showDeleteDialog(context, note.id!);
        }
      },
      onTap: () {
        // Not detay sayfasına git
        // context.go('/note/${note.id}');
      },
    );
  }

  /// Edit Note sayfasına yönlendir
  void _navigateToEditNote(BuildContext context, NoteModel note) {
    // GoRouter ile EditNoteView'a git
    context.push(
      '/editNote/${note.id}?title=${Uri.encodeComponent(note.title ?? '')}&content=${Uri.encodeComponent(note.content ?? '')}&startDate=${Uri.encodeComponent(note.startDate ?? '')}&endDate=${Uri.encodeComponent(note.endDate ?? '')}&pinned=${note.pinned ?? false}&tags=${note.tags?.map((tag) => tag.name).join(',') ?? ''}',
    );
  }

  void _showDeleteDialog(BuildContext context, String noteId) {
    showDialog<void>(
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
