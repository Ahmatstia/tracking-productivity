import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:life_os_productivity/features/analytics/domain/daily_review_model.dart';
import 'package:life_os_productivity/features/tasks/domain/task_model.dart';
import 'package:life_os_productivity/features/focus/domain/focus_session_model.dart';
import 'package:life_os_productivity/features/gamification/domain/user_stats_model.dart';

// ─── Analytics Summary data class ────────────────────────────────────────────
class WeeklyAnalytics {
  final List<DayStats> days; // Last 7 days
  final int totalFocusMinutes;
  final double avgProductivityScore;
  final int tasksCompletedWeek;
  final String peakProductivityDay;
  final Map<String, int> dailyScores; // All-time for heatmap

  const WeeklyAnalytics({
    required this.days,
    required this.totalFocusMinutes,
    required this.avgProductivityScore,
    required this.tasksCompletedWeek,
    required this.peakProductivityDay,
    required this.dailyScores,
  });
}

class DayStats {
  final DateTime date;
  final int tasksCompleted;
  final int totalTasks;
  final int focusMinutes;
  final int score;

  const DayStats({
    required this.date,
    required this.tasksCompleted,
    required this.totalTasks,
    required this.focusMinutes,
    required this.score,
  });

  double get completionRate => totalTasks == 0 ? 0 : tasksCompleted / totalTasks;
}

// ─── Providers ────────────────────────────────────────────────────────────────

// Daily Review box provider
final dailyReviewBoxProvider = Provider<Box<DailyReviewModel>>((ref) {
  return Hive.box<DailyReviewModel>('daily_review_box');
});

// Today's review
final todayReviewProvider = Provider<DailyReviewModel?>((ref) {
  final box = ref.watch(dailyReviewBoxProvider);
  final key = _dateKey(DateTime.now());
  return box.get(key);
});

// Weekly analytics computed from existing data
final weeklyAnalyticsProvider = Provider<WeeklyAnalytics>((ref) {
  final taskBox = Hive.box<TaskModel>('tasks_box');
  final focusBox = Hive.box<FocusSessionModel>('focus_session_box');
  final statsBox = Hive.box<UserStatsModel>('user_stats_box');

  final tasks = taskBox.values.toList();
  final focusSessions = focusBox.values.toList();
  final userStats = statsBox.isNotEmpty ? statsBox.getAt(0) : null;

  final now = DateTime.now();
  final List<DayStats> dayStats = [];

  for (int i = 6; i >= 0; i--) {
    final day = now.subtract(Duration(days: i));
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final dayTasks = tasks.where((t) =>
        t.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
        t.date.isBefore(dayEnd)).toList();

    final dayFocus = focusSessions.where((f) =>
        f.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
        f.date.isBefore(dayEnd) &&
        f.isFocusMode).toList();

    final completed = dayTasks.where((t) => t.isCompleted).length;
    final total = dayTasks.length;
    final focusMin = dayFocus.fold<int>(0, (sum, f) => sum + (f.durationSeconds ~/ 60));

    // Score: 50% task completion + 50% focus (max 120 min = 100%)
    final taskScore = total == 0 ? 0 : (completed / total * 50).round();
    final focusScore = (focusMin / 120 * 50).clamp(0, 50).round();
    final score = taskScore + focusScore;

    dayStats.add(DayStats(
      date: dayStart,
      tasksCompleted: completed,
      totalTasks: total,
      focusMinutes: focusMin,
      score: score,
    ));
  }

  final totalFocus = dayStats.fold<int>(0, (s, d) => s + d.focusMinutes);
  final totalTasksDone = dayStats.fold<int>(0, (s, d) => s + d.tasksCompleted);
  final avgScore = dayStats.isEmpty ? 0.0 : dayStats.fold<int>(0, (s, d) => s + d.score) / dayStats.length;

  // Peak day
  final peak = dayStats.reduce((a, b) => a.score >= b.score ? a : b);
  final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  final peakDay = days[peak.date.weekday - 1];

  return WeeklyAnalytics(
    days: dayStats,
    totalFocusMinutes: totalFocus,
    avgProductivityScore: avgScore,
    tasksCompletedWeek: totalTasksDone,
    peakProductivityDay: peakDay,
    dailyScores: userStats?.dailyScores ?? {},
  );
});

// Save / update a daily review
class DailyReviewNotifier extends StateNotifier<DailyReviewModel?> {
  final Box<DailyReviewModel> _box;

  DailyReviewNotifier(this._box) : super(null) {
    _load();
  }

  void _load() {
    state = _box.get(_dateKey(DateTime.now()));
  }

  Future<void> saveReview(DailyReviewModel review) async {
    await _box.put(review.id, review);
    state = review;
  }

  Future<void> updateMood(int mood) async {
    final existing = state ?? _emptyToday();
    final updated = DailyReviewModel(
      id: existing.id,
      date: existing.date,
      moodRating: mood,
      whatWentWell: existing.whatWentWell,
      whatToImprove: existing.whatToImprove,
      tasksCompleted: existing.tasksCompleted,
      totalTasks: existing.totalTasks,
      focusMinutes: existing.focusMinutes,
      productivityScore: existing.productivityScore,
    );
    await saveReview(updated);
  }

  DailyReviewModel _emptyToday() {
    final today = DateTime.now();
    return DailyReviewModel(
      id: _dateKey(today),
      date: today,
    );
  }
}

final dailyReviewProvider =
    StateNotifierProvider<DailyReviewNotifier, DailyReviewModel?>((ref) {
  final box = ref.watch(dailyReviewBoxProvider);
  return DailyReviewNotifier(box);
});

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
