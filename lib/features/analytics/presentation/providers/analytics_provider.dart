import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';
import 'package:life_os_productivity/features/focus/presentation/providers/focus_session_provider.dart';
import 'package:life_os_productivity/features/gamification/presentation/providers/stats_provider.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/time_block_provider.dart';

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
  final allBlocks = ref.watch(timeBlockProvider); // Add Time Blocks

  final now = DateTime.now();
  final List<DayStats> dayStats = [];

  for (int i = 6; i >= 0; i--) {
    final day = now.subtract(Duration(days: i));
    final dayYMD = DateTime(day.year, day.month, day.day);
    
    // ── Filter Tasks ───────────────────────────
    final dayTasks = tasks.where((t) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      return tDate == dayYMD;
    }).toList();

    // ── Filter Focus Sessions ──────────────────
    final dayFocus = focusSessions.where((f) {
      final fDate = DateTime(f.date.year, f.date.month, f.date.day);
      return fDate == dayYMD && f.isFocusMode;
    }).toList();

    // ── Filter Time Blocks (Jadwal) ────────────
    final dayBlocks = allBlocks.where((b) {
      final bDate = DateTime(b.date.year, b.date.month, b.date.day);
      return bDate == dayYMD;
    }).toList();

    final completedTasks = dayTasks.where((t) => t.isCompleted).length;
    final totalTasks = dayTasks.length;
    
    final completedBlocks = dayBlocks.where((b) => b.isCompleted).length;
    final totalBlocks = dayBlocks.length;

    final focusMin = dayFocus.fold<int>(0, (sum, f) => sum + (f.durationSeconds ~/ 60));

    // ── Balanced Score Calculation (0-100) ─────
    // Logic: 50% Tasks, 50% Blocks.
    // If one is empty, the other takes 100% weight.
    double dailyScoreVal = 0;
    
    if (totalTasks > 0 && totalBlocks > 0) {
      // Both exist: 50/50 split
      dailyScoreVal = (completedTasks / totalTasks * 50) + (completedBlocks / totalBlocks * 50);
    } else if (totalTasks > 0) {
      // Only tasks exist: 100% tasks
      dailyScoreVal = (completedTasks / totalTasks * 100);
    } else if (totalBlocks > 0) {
      // Only blocks exist: 100% blocks
      dailyScoreVal = (completedBlocks / totalBlocks * 100);
    } else {
      // Nothing scheduled: 0 score
      dailyScoreVal = 0;
    }

    dayStats.add(DayStats(
      date: dayYMD,
      tasksCompleted: completedTasks,
      totalTasks: totalTasks,
      focusMinutes: focusMin,
      score: dailyScoreVal.round(),
    ));
  }

  final totalFocus = dayStats.fold<int>(0, (s, d) => s + d.focusMinutes);
  final totalTasksDone = dayStats.fold<int>(0, (s, d) => s + d.tasksCompleted);
  final avgScore = dayStats.isEmpty ? 0.0 : dayStats.fold<int>(0, (s, d) => s + d.score) / dayStats.length;

  // Peak day logic: only identify if there's at least one day with score > 0
  final maxScore = dayStats.fold<int>(0, (max, d) => d.score > max ? d.score : max);
  String peakDayLabel = "-";
  
  if (maxScore > 0) {
    final peak = dayStats.reduce((a, b) => a.score >= b.score ? a : b);
    final dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    peakDayLabel = dayNames[peak.date.weekday - 1];
  }

  return WeeklyAnalytics(
    days: dayStats,
    totalFocusMinutes: totalFocus,
    avgProductivityScore: avgScore,
    tasksCompletedWeek: totalTasksDone,
    peakProductivityDay: peakDayLabel,
    dailyScores: userStats.stats.dailyScores,
  );
});
