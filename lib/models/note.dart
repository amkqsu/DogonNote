import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String? aiSummary;

  @HiveField(4)
  String? aiCategory;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.aiSummary,
    this.aiCategory,
    required this.updatedAt,
    required this.createdAt,
  });
}
