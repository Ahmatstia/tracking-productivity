import 'package:hive/hive.dart';

part 'daily_review_model.g.dart';

@HiveType(typeId: 9)
class DailyReviewModel extends HiveObject {
  @HiveField(0)
  String id; // Format: YYYY-MM-DD

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int moodRating; // 1-5

  @HiveField(3)
  String whatWentWell;

  @HiveField(4)
  String whatToImprove;

  @HiveField(5)
  int tasksCompleted;

  @HiveField(6)
  int totalTasks;

  @HiveField(7)
  int focusMinutes;

  @HiveField(8)
  int productivityScore; // 0-100

  DailyReviewModel({
    required this.id,
    required this.date,
    this.moodRating = 3,
    this.whatWentWell = '',
    this.whatToImprove = '',
    this.tasksCompleted = 0,
    this.totalTasks = 0,
    this.focusMinutes = 0,
    this.productivityScore = 0,
  });
}
