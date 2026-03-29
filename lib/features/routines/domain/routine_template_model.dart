import 'package:hive/hive.dart';

part 'routine_template_model.g.dart';

@HiveType(typeId: 8)
class RoutineBlockModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String startTime;

  @HiveField(2)
  String endTime;

  @HiveField(3)
  String category;

  RoutineBlockModel({
    required this.title,
    required this.startTime,
    required this.endTime,
    this.category = 'personal',
  });
}

@HiveType(typeId: 7)
class RoutineTemplateModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<RoutineBlockModel> blocks;

  @HiveField(3)
  List<int> assignedDays; // 1 (Mon) - 7 (Sun), hari otomatis diterapkan

  @HiveField(4)
  int colorCode;

  RoutineTemplateModel({
    required this.id,
    required this.name,
    required this.blocks,
    this.assignedDays = const [],
    this.colorCode = 0xFF007BFF, // Default Blue
  });
}
