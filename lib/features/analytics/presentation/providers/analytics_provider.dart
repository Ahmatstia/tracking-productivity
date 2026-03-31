import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';
import 'package:life_os_productivity/features/focus/presentation/providers/focus_session_provider.dart';
import 'package:life_os_productivity/features/gamification/presentation/providers/stats_provider.dart';

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

// Weekly analytics computed from reactive providers
final weeklyAnalyticsProvider = Provider<WeeklyAnalytics>((ref) {
  // Watch providers for actual reactivity
  final tasks = ref.watch(taskProvider);
  final focusSessions = ref.watch(focusSessionProvider);
  final userStats = ref.watch(gamificationProvider);

  final now = DateTime.now();
  final List<DayStats> dayStats = [];

  for (int i = 6; i >= 0; i--) {
    final day = now.subtract(Duration(days: i));
    final dayYMD = DateTime(day.year, day.month, day.day);
    
    // Filter tasks for this specific YMD
    final dayTasks = tasks.where((t) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      return tDate == dayYMD;
    }).toList();

    // Filter focus sessions for this specific YMD
    final dayFocus = focusSessions.where((f) {
      final fDate = DateTime(f.date.year, f.date.month, f.date.day);
      return fDate == dayYMD && f.isFocusMode;
    }).toList();

    final completed = dayTasks.where((t) => t.isCompleted).length;
    final total = dayTasks.length;
    final focusMin = dayFocus.fold<int>(0, (sum, f) => sum + (f.durationSeconds ~/ 60));

    // Score calculation (0-100)
    final taskScore = total == 0 ? 0 : (completed / total * 50).round();
    final focusScore = (focusMin / 120 * 50).clamp(0, 50).round();
    final score = taskScore + focusScore;

    dayStats.add(DayStats(
      date: dayYMD,
      tasksCompleted: completed,
      totalTasks: total,
      focusMinutes: focusMin,
      score: score,
    ));
  }

  final totalFocus = dayStats.fold<int>(0, (s, d) => s + d.focusMinutes);
  final totalTasksDone = dayStats.fold<int>(0, (s, d) => s + d.tasksCompleted);
  final avgScore = dayStats.isEmpty ? 0.0 : dayStats.fold<int>(0, (s, d) => s + d.score) / dayStats.length;

  // Peak day logic
  final peak = dayStats.reduce((a, b) => a.score >= b.score ? a : b);
  final dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  final peakDayLabel = dayNames[peak.date.weekday - 1];

  return WeeklyAnalytics(
    days: dayStats,
    totalFocusMinutes: totalFocus,
    avgProductivityScore: avgScore,
    tasksCompletedWeek: totalTasksDone,
    peakProductivityDay: peakDayLabel,
    dailyScores: userStats.stats.dailyScores,
  );
});
