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
    this.initialStartDate,
    this.initialEndDate,
    this.initialPinned = false,
    this.initialTags = const [],
    super.key,
  });

  final String noteId;
  final String initialTitle;
  final String initialContent;
  final String? initialStartDate;
  final String? initialEndDate;
  final bool initialPinned;
  final List<NoteTag> initialTags;

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _startDateController = TextEditingController(
      text: widget.initialStartDate ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.initialEndDate ?? '',
    );

    // Cubit'i initialize et
    context.read<EditNoteCubit>().initializeNote(
      noteId: widget.noteId,
      title: widget.initialTitle,
      content: widget.initialContent,
      startDate: widget.initialStartDate,
      endDate: widget.initialEndDate,
      pinned: widget.initialPinned,
      tags: widget.initialTags,
    );
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
        title: const Text('Notu Düzenle'),
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
        child: BlocConsumer<EditNoteCubit, EditNoteState>(
          listener: (context, state) {
            if (state.status == EditNoteStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Not başarıyla güncellendi!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Form'u resetle
              _resetForm(context);
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

            // Tarih controller'larını state ile senkronize et
            if (_startDateController.text != (state.startDate ?? '')) {
              _startDateController.text = state.startDate ?? '';
            }
            if (_endDateController.text != (state.endDate ?? '')) {
              _endDateController.text = state.endDate ?? '';
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
                      _buildTitleSection(),
                      const SizedBox(height: 20),
                      _buildContentSection(),
                      const SizedBox(height: 20),
                      _buildDateSection(),
                      const SizedBox(height: 20),
                      _buildPinSection(),
                      const SizedBox(height: 20),
                      _buildTagsSection(),
                      const SizedBox(height: 32),
                      _buildUpdateButton(),
                      const SizedBox(height: 32),
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

  /// Notu güncelle
  void _updateNote(BuildContext context, EditNoteState state) {
    if (_formKey.currentState!.validate()) {
      context.read<EditNoteCubit>().updateNote();
    }
  }

  /// Formu orijinal haline geri al
  void _resetForm(BuildContext context) {
    context.read<EditNoteCubit>().resetForm();
    final state = context.read<EditNoteCubit>().state;
    _titleController.text = state.title;
    _contentController.text = state.content;
    _startDateController.text = state.startDate ?? '';
    _endDateController.text = state.endDate ?? '';
  }

  /// Başlangıç tarihi seç
  Future<void> _selectStartDate(BuildContext context) async {
    final cubit = context.read<EditNoteCubit>();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted) return;

    if (picked != null) {
      final formattedDate = DateFormatter.formatToDisplayFormat(picked);
      cubit.startDateChanged(formattedDate);
    } else {
      // Tarih seçilmediğinde null gönder
      cubit.startDateChanged(null);
    }
  }

  /// Bitiş tarihi seç
  Future<void> _selectEndDate(BuildContext context) async {
    final cubit = context.read<EditNoteCubit>();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted) return;

    if (picked != null) {
      final formattedDate = DateFormatter.formatToDisplayFormat(picked);
      cubit.endDateChanged(formattedDate);
    } else {
      // Tarih seçilmediğinde null gönder
      cubit.endDateChanged(null);
    }
  }

  /// Tag seçici göster
  void _showTagSelector(BuildContext context) {
    final currentTags = context.read<EditNoteCubit>().state.tags;
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
                                  context.read<EditNoteCubit>().tagAdded(tag);
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

  /// Section card widget'ı oluştur
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
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
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
            const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  /// Not başlığı bölümü
  Widget _buildTitleSection() {
    return _buildSectionCard(
      title: 'Not Başlığı',
      icon: Icons.title,
      child: AppTextField(
        controller: _titleController,
        hintText: 'Not başlığınızı girin...',
        prefix: const Icon(Icons.edit),
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
    );
  }

  /// Not içeriği bölümü
  Widget _buildContentSection() {
    return _buildSectionCard(
      title: 'Not İçeriği',
      icon: Icons.description,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 200),
        child: AppTextField(
          controller: _contentController,
          hintText: 'Not içeriğinizi yazın...',
          maxLines: 10,
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
    );
  }

  /// Tarih aralığı bölümü
  Widget _buildDateSection() {
    return _buildSectionCard(
      title: 'Tarih Aralığı',
      icon: Icons.calendar_month,
      child: Column(
        children: [
          _buildDateSelector(
            context: context,
            controller: _startDateController,
            label: 'Başlangıç Tarihi',
            icon: Icons.calendar_today,
            onTap: () => _selectStartDate(context),
          ),
          const SizedBox(height: 12),
          _buildDateSelector(
            context: context,
            controller: _endDateController,
            label: 'Bitiş Tarihi',
            icon: Icons.event,
            onTap: () => _selectEndDate(context),
          ),
        ],
      ),
    );
  }

  /// Notu sabitle bölümü
  Widget _buildPinSection() {
    return BlocBuilder<EditNoteCubit, EditNoteState>(
      builder: (context, state) {
        return _buildSectionCard(
          title: 'Notu Sabitle',
          icon: Icons.push_pin,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.push_pin,
                  color: state.pinned ? Colors.amber : Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bu notu listenin üstünde göster',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.pinned ? 'Not sabitlendi' : 'Not sabitlenmedi',
                        style: TextStyle(
                          color: state.pinned ? Colors.amber : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.pinned,
                  onChanged: (value) {
                    context.read<EditNoteCubit>().pinnedChanged(pinned: value);
                  },
                  activeColor: Colors.amber,
                  activeTrackColor: Colors.amber.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Etiketler bölümü
  Widget _buildTagsSection() {
    return BlocBuilder<EditNoteCubit, EditNoteState>(
      builder: (context, state) {
        return _buildSectionCard(
          title: 'Etiketler',
          icon: Icons.label,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      state.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tag.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () {
                                      context.read<EditNoteCubit>().tagRemoved(
                                        tag,
                                      );
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showTagSelector(context),
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(
                    state.tags.isEmpty ? 'Etiket Ekle' : 'Başka Etiket Ekle',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Güncelle butonu bölümü
  Widget _buildUpdateButton() {
    return BlocBuilder<EditNoteCubit, EditNoteState>(
      builder: (context, state) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha: 0.8),
                Colors.teal.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed:
                state.status == EditNoteStatus.loading ||
                        !state.isValid ||
                        !state.hasChanges
                    ? null
                    : () => _updateNote(context, state),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child:
                state.status == EditNoteStatus.loading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.update, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Notu Güncelle',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
