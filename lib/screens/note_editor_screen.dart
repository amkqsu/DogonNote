import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/gemini_service.dart';
import '../services/notes_repository.dart';
import '../theme/app_theme.dart';

class NoteEditorScreen extends StatefulWidget {
  final NotesRepository repository;
  final Note? existing;
  final String? initialContent;

  const NoteEditorScreen({
    super.key,
    required this.repository,
    this.existing,
    this.initialContent,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  static const List<String> _categories = [
    'İş',
    'Fikir',
    'Kişisel',
    'Alışveriş',
    'Sağlık',
    'Eğitim',
    'Diğer',
  ];

  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late String _selectedCategory;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = TextEditingController(
      text: widget.existing?.content ?? widget.initialContent ?? '',
    );
    _selectedCategory = widget.existing?.aiCategory ?? 'Diğer';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _contentCtrl.text = _contentCtrl.text.isEmpty
            ? data.text!
            : '${_contentCtrl.text}\n${data.text!}';
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pano boş görünüyor')),
      );
    }
  }

  Future<void> _saveNote() async {
    if (_contentCtrl.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    setState(() => _saving = true);

    String? summary;
    try {
      final result = await GeminiService.summarizeAndCategorize(_contentCtrl.text);
      summary = result.summary;
    } catch (_) {}

    final note = widget.existing ??
        Note(
          id: const Uuid().v4(),
          title: _titleCtrl.text,
          content: _contentCtrl.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    note
      ..title = _titleCtrl.text.trim().isEmpty
          ? (_contentCtrl.text.split('\n').first)
          : _titleCtrl.text
      ..content = _contentCtrl.text
      ..aiSummary = summary ?? note.aiSummary
      ..aiCategory = _selectedCategory
      ..updatedAt = DateTime.now();

    await widget.repository.save(note);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Yeni not' : 'Notu düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste_rounded),
            tooltip: 'Panodan yapıştır',
            onPressed: _pasteFromClipboard,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Başlık (boş bırakılabilir)',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Notunu yaz ya da panodan yapıştır...',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kategori',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final selected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.violet,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.stroke),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.black : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.violet,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _saving ? null : _saveNote,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
