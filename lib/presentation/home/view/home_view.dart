import 'dart:async';

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
  Timer? _deleteTimer;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında notları yükle
    context.read<HomeBloc>().add(const LoadNotes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _deleteTimer?.cancel();
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

              // AI önerisi başarılı olduğunda dialog göster
              if (state.aiSuggestionStatus == AiSuggestionStatus.success &&
                  state.aiSuggestion != null) {
                _showAiSuggestionDialog(context, state.aiSuggestion!);
                // Dialog gösterildikten sonra state'i temizle
                context.read<HomeBloc>().add(const ClearAiSuggestion());
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
                  _buildTagFilter(state),
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

  /// Tag filtreleme bölümü
  Widget _buildTagFilter(HomeState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve temizle butonu
          Row(
            children: [
              const Text(
                'Etiketlere Göre Filtrele',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (state.selectedTags.isNotEmpty)
                TextButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const ClearTagFilter());
                  },
                  child: const Text(
                    'Temizle',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Tag seçim alanı
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  NoteTag.values.map((tag) {
                    final isSelected = state.selectedTags.contains(tag);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(tag.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          final newSelectedTags = [...state.selectedTags];
                          if (selected) {
                            newSelectedTags.add(tag);
                          } else {
                            newSelectedTags.remove(tag);
                          }
                          context.read<HomeBloc>().add(
                            TagFilterChanged(newSelectedTags),
                          );
                        },
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        selectedColor: _getTagColor(tag).withValues(alpha: 0.3),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.green,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color:
                              isSelected
                                  ? _getTagColor(tag)
                                  : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Not içeriği - Pinlenmiş ve normal notlar
  Widget _buildNotesContent(HomeState state) {
    if (state.status == HomeStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HomeStatus.success) {
      // Arama terimine ve seçili tag'lere göre notları filtrele
      final filteredNotes = _filterNotes(
        state.notes,
        state.searchTerm,
        state.selectedTags,
      );
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
              child: _buildEmptyState(
                state.searchTerm.isNotEmpty || state.selectedTags.isNotEmpty,
              ),
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
  Widget _buildEmptyState(bool isFiltering) {
    if (isFiltering) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Filtre sonucu bulunamadı',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Farklı filtre seçenekleri deneyin',
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

  /// Notları filtrele (arama terimi ve tag'lere göre)
  List<NoteModel> _filterNotes(
    List<NoteModel> notes,
    String searchTerm,
    List<NoteTag> selectedTags,
  ) {
    var filteredNotes = notes;

    // Arama terimine göre filtrele
    if (searchTerm.isNotEmpty) {
      final searchTermLower = searchTerm.toLowerCase();
      filteredNotes =
          filteredNotes.where((note) {
            final title = (note.title ?? '').toLowerCase();
            final content = (note.content ?? '').toLowerCase();
            return title.contains(searchTermLower) ||
                content.contains(searchTermLower);
          }).toList();
    }

    // Tag'lere göre filtrele
    if (selectedTags.isNotEmpty) {
      filteredNotes =
          filteredNotes.where((note) {
            if (note.tags == null || note.tags!.isEmpty) return false;
            // Seçili tag'lerden en az birini içeren notları göster
            return selectedTags.any(
              (selectedTag) => note.tags!.contains(selectedTag),
            );
          }).toList();
    }

    return filteredNotes;
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
    final homeBloc = context.read<HomeBloc>();
    final currentState = homeBloc.state;
    final noteToDelete = currentState.notes.firstWhere(
      (note) => note.id == noteId,
    );

    // State'i güncelle (notu geçici olarak kaldır)
    homeBloc.add(TemporarilyRemoveNote(noteId));

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
            homeBloc.add(RestoreNote(noteToDelete));
          },
        ),
      ),
    );

    // 5 saniye sonra gerçek silme işlemini yap
    _deleteTimer = Timer(const Duration(seconds: 5), () {
      // Context'in hala geçerli olup olmadığını kontrol et
      if (mounted) {
        final currentNotes = homeBloc.state.notes;
        if (!currentNotes.any((note) => note.id == noteId)) {
          homeBloc.add(DeleteNote(noteId));
        }
      }
    });
  }

  /// AI önerisi al
  void _getAiSuggestion(BuildContext context, String noteId) {
    context.read<HomeBloc>().add(GetAiSuggestion(noteId));
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
}
