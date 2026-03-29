import 'package:hive/hive.dart';

part 'user_stats_model.g.dart';

@HiveType(typeId: 6)
class UserStatsModel extends HiveObject {
  @HiveField(0)
  int currentStreak;

  @HiveField(1)
  int longestStreak;

  @HiveField(2)
  DateTime? lastActiveDate;

  // Key: YYYY-MM-DD -> Value: Productivity Score (0 - 100)
  @HiveField(3)
  Map<String, int> dailyScores;

  UserStatsModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    Map<String, int>? dailyScores,
  }) : dailyScores = dailyScores ?? {};

  // Fungsi utilitas untuk mencatat login / interaksi harian
  void checkAndUpdateStreak(DateTime today) {
    if (lastActiveDate == null) {
      currentStreak = 1;
      longestStreak = 1;
      lastActiveDate = today;
      return;
    }

    // Jika harinya tepat 1 hari setelah lastActive
    final diff = DateTime(today.year, today.month, today.day).difference(
        DateTime(lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day));

    if (diff.inDays == 1) {
      // Masih hit streak!
      currentStreak++;
      if (currentStreak > longestStreak) longestStreak = currentStreak;
    } else if (diff.inDays > 1) {
      // Streak putus karena terlewat
      currentStreak = 1; // Kembali ke 1
    }
    
    lastActiveDate = today;
  }
}
