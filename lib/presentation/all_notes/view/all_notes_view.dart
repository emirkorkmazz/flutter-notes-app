import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/core.dart';
import '/data/data.dart';
import '../cubit/cubit.dart';

class AllNotesView extends StatefulWidget {
  const AllNotesView({super.key});

  @override
  State<AllNotesView> createState() => _AllNotesViewState();
}

class _AllNotesViewState extends State<AllNotesView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _deleteTimer;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında tüm notları yükle
    context.read<AllNotesCubit>().loadAllNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _deleteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
        child: BlocConsumer<AllNotesCubit, AllNotesState>(
          listener: (context, state) {
            if (state.status == AllNotesStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }

            // AI önerisi başarılı olduğunda dialog göster
            if (state.aiSuggestionStatus == AiSuggestionStatus.success &&
                state.aiSuggestion != null) {
              _showAiSuggestionDialog(context, state.aiSuggestion!);
              // Dialog gösterildikten sonra state'i temizle
              context.read<AllNotesCubit>().clearAiSuggestion();
            }

            // AI önerisi hatası
            if (state.aiSuggestionStatus == AiSuggestionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.aiSuggestionError),
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
                Expanded(child: _buildAllNotesContent(state)),
              ],
            );
          },
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
            'Tüm Notlar',
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
          context.read<AllNotesCubit>().searchChanged(value);
        },
        decoration: InputDecoration(
          hintText: 'Tüm notlarda ara...',
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

  /// Tüm notlar içeriği
  Widget _buildAllNotesContent(AllNotesState state) {
    if (state.status == AllNotesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AllNotesStatus.success) {
      // Arama terimine göre notları filtrele
      final filteredNotes = _filterNotes(state.notes, state.searchTerm);

      if (filteredNotes.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<AllNotesCubit>().refreshAllNotes();
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
          await context.read<AllNotesCubit>().refreshAllNotes();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tüm Notlar başlığı
              _buildSectionTitle('Tüm Notlar (${filteredNotes.length})'),
              const SizedBox(height: 8),
              _buildNotesList(filteredNotes),
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
      onAiSuggestion:
          note.id != null
              ? () {
                _getAiSuggestion(context, note.id!);
              }
              : null,
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
                  _deleteNoteWithUndo(context, noteId);
                },
                child: const Text('Sil'),
              ),
            ],
          ),
    );
  }

  void _deleteNoteWithUndo(BuildContext context, String noteId) {
    // Önce notu listeden kaldır (geçici olarak)
    final allNotesCubit = context.read<AllNotesCubit>();
    final currentState = allNotesCubit.state;
    final noteToDelete = currentState.notes.firstWhere(
      (note) => note.id == noteId,
    );

    // State'i güncelle (notu geçici olarak kaldır)
    allNotesCubit.temporarilyRemoveNote(noteId);

    // Snackbar göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Not başarılı bir şekilde silindi.'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            // Timer'ı iptal et
            _deleteTimer?.cancel();
            // Notu geri ekle
            allNotesCubit.restoreNote(noteToDelete);
          },
        ),
      ),
    );

    // 5 saniye sonra gerçek silme işlemini yap
    _deleteTimer = Timer(const Duration(seconds: 5), () {
      // Context'in hala geçerli olup olmadığını kontrol et
      if (mounted) {
        final currentNotes = allNotesCubit.state.notes;
        if (!currentNotes.any((note) => note.id == noteId)) {
          allNotesCubit.deleteNote(noteId);
        }
      }
    });
  }

  /// AI önerisi al
  void _getAiSuggestion(BuildContext context, String noteId) {
    context.read<AllNotesCubit>().getAiSuggestion(noteId);
  }

  /// AI önerisi dialog'unu göster
  void _showAiSuggestionDialog(
    BuildContext context,
    GetAiSuggestionData aiSuggestion,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AiSuggestionDialog(aiSuggestion: aiSuggestion),
    );
  }
}
