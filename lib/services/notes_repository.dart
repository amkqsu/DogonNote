import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class NotesRepository {
  static const String boxName = 'notes';
  late Box<Note> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    _box = await Hive.openBox<Note>(boxName);
  }

  List<Note> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> save(Note note) async {
    await _box.put(note.id, note);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Note? get(String id) => _box.get(id);
}
