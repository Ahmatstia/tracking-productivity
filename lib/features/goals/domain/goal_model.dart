import 'package:hive/hive.dart';

// Kita beri nama part agar bisa di-generate oleh hive_generator nanti
part 'goal_model.g.dart';

@HiveType(typeId: 1)
class SubTask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  SubTask({
    required this.title,
    this.isCompleted = false,
  });
}

@HiveType(typeId: 0)
class GoalModel extends HiveObject {
  @HiveField(0)
  String title; // Judul Mimpi (Contoh: Beli Rumah)

  @HiveField(1)
  String description; // Alasan/Detail

  @HiveField(2)
  double progress; // 0.0 sampai 1.0 (0% - 100%)

  @HiveField(3)
  DateTime? targetDate; // Kapan mimpi ini ingin dicapai (opsional)

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  List<SubTask> subTasks;

  GoalModel({
    required this.title,
    required this.description,
    this.progress = 0.0,
    this.targetDate,
    this.isCompleted = false,
    List<SubTask>? subTasks,
  }) : subTasks = subTasks ?? [];
}
