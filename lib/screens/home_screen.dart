import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';
import '../services/gemini_service.dart';
import '../services/notes_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotesRepository _repo = NotesRepository();
  final TextEditingController _searchCtrl = TextEditingController();
  List<Note> _notes = [];
  List<Note>? _searchResults; // null => arama aktif değil
  String _activeChip = 'Tümü';
  bool _searching = false;
  bool _ready = false;

  static const _chips = ['Tümü', 'İş', 'Fikir', 'Kişisel', 'Alışveriş'];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.init();
    _refresh();
    setState(() => _ready = true);
  }

  void _refresh() {
    setState(() => _notes = _repo.getAll());
  }

  List<Note> get _visibleNotes {
    final base = _searchResults ?? _notes;
    if (_activeChip == 'Tümü') return base;
    return base.where((n) => n.aiCategory == _activeChip).toList();
  }

  Future<void> _runSemanticSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    setState(() => _searching = true);
    try {
      final ids = await GeminiService.semanticSearch(
        query: query,
        notes: _notes
            .map((n) => {'id': n.id, 'title': n.title, 'content': n.content})
            .toList(),
      );
      final byId = {for (final n in _notes) n.id: n};
      setState(() {
        _searchResults = ids.map((id) => byId[id]).whereType<Note>().toList();
      });
    } catch (_) {
      // AI araması başarısız olursa basit metin aramasına düş.
      final q = query.toLowerCase();
      setState(() {
        _searchResults = _notes
            .where((n) =>
                n.title.toLowerCase().contains(q) ||
                n.content.toLowerCase().contains(q))
            .toList();
      });
    } finally {
      setState(() => _searching = false);
    }
  }

  Future<void> _pasteAndCreate() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text;
    if (text == null || text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pano boş görünüyor')),
        );
      }
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(repository: _repo, initialContent: text),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: AppColors.void_,
        body: Center(child: CircularProgressIndicator(color: AppColors.violet)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            children: [
              TextSpan(text: 'Dogon'),
              TextSpan(text: 'Note', style: TextStyle(color: AppColors.violet)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: _runSemanticSearch,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Anlamına göre ara: 'kira ödemesi'...",
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.violet, size: 20),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.violet),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.violetDim,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('AI',
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFC9B3FF))),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              itemCount: _chips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final chip = _chips[i];
                final active = chip == _activeChip;
                return ChoiceChip(
                  label: Text(chip == 'Tümü' ? chip : '✦ $chip'),
                  selected: active,
                  onSelected: (_) => setState(() => _activeChip = chip),
                  selectedColor: AppColors.violet,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.stroke),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _visibleNotes.isEmpty
                ? Center(
                    child: Text(
                      'Henüz not yok.\nSağ alttaki + ile başla.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                    itemCount: _visibleNotes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final note = _visibleNotes[i];
                      return NoteCard(
                        note: note,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditorScreen(
                                  repository: _repo, existing: note),
                            ),
                          );
                          _refresh();
                        },
                        onDelete: () async {
                          await _repo.delete(note.id);
                          _refresh();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'paste',
            backgroundColor: AppColors.elevated,
            foregroundColor: AppColors.textSecondary,
            elevation: 0,
            onPressed: _pasteAndCreate,
            child: const Icon(Icons.content_paste_rounded, size: 18),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'new',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(repository: _repo),
                ),
              );
              _refresh();
            },
            child: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
