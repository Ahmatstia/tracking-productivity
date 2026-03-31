import 'package:hive/hive.dart';

part 'time_block_model.g.dart';

@HiveType(typeId: 3)
class TimeBlockModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String startTime; // Format: "HH:mm"

  @HiveField(3)
  String endTime; // Format: "HH:mm"

  @HiveField(4)
  String category; // work, health, learning, personal

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  String? linkedTaskId;

  @HiveField(8)
  String? note;

  @HiveField(9)
  String? sourceRoutineId;

  TimeBlockModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.category = 'personal',
    required this.date,
    this.isCompleted = false,
    this.linkedTaskId,
    this.note,
    this.sourceRoutineId,
  });

  // Helper: convert "HH:mm" to minutes since midnight
  int get startMinutes {
    final parts = startTime.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  int get endMinutes {
    final parts = endTime.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  int get durationMinutes => endMinutes - startMinutes;
}
