import 'package:hive/hive.dart';

part 'habit_pattern_model.g.dart';

@HiveType(typeId: 4)
class HabitPatternModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String startTime; // "HH:mm"

  @HiveField(3)
  String endTime; // "HH:mm"

  @HiveField(4)
  String category;

  @HiveField(5)
  List<int> daysOfWeek; // 1=Senin, 2=Selasa, ... 7=Minggu

  @HiveField(6)
  int occurrenceCount; // berapa kali sudah dilakukan

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  DateTime? lastAppliedDate;

  @HiveField(9)
  String? note;

  HabitPatternModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.category = 'personal',
    this.daysOfWeek = const [],
    this.occurrenceCount = 1,
    this.isActive = true,
    this.lastAppliedDate,
    this.note,
  });

  // Apakah habit ini aktif untuk hari tertentu (weekday: 1=Senin..7=Minggu)
  bool isActiveForDay(int weekday) {
    if (daysOfWeek.isEmpty) return true; // berlaku semua hari
    return daysOfWeek.contains(weekday);
  }

  // Sudah cukup sering (>= 3) untuk dianggap habit solid
  bool get isEstablished => occurrenceCount >= 3;
}
