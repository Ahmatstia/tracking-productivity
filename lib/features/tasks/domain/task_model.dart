import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  String category;

  @HiveField(6)
  String? startTime; // "HH:mm" — waktu mulai (opsional)

  @HiveField(7)
  String? endTime; // "HH:mm" — waktu selesai (opsional)

  @HiveField(8)
  int priority; // 0 = Normal, 1 = Penting, 2 = Urgent

  @HiveField(9)
  bool isCarriedOver; // true jika dipindah dari hari sebelumnya

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.isCompleted = false,
    this.category = 'Tasks',
    this.startTime,
    this.endTime,
    this.priority = 0,
    this.isCarriedOver = false,
  });

  bool get isScheduled => startTime != null && endTime != null;

  bool get isUrgent => priority == 2;
  bool get isImportant => priority == 1;
}
