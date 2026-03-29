import 'package:hive/hive.dart';

// Menandakan adapter perlu digenerate otomatis
part 'focus_session_model.g.dart';

@HiveType(typeId: 5)
class FocusSessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  final String? taskId; // Boleh null jika fokus bebas (tanpa milih task)

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final int durationSeconds; // Berapa lama fokus dalam detik

  @HiveField(4)
  final bool isFocusMode; // True untuk fokus kerja, False untuk breaking time (jangan dihitung ke skor)

  FocusSessionModel({
    required this.id,
    this.taskId,
    required this.date,
    required this.durationSeconds,
    this.isFocusMode = true,
  });
}
