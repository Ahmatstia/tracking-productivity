import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_os_productivity/features/gamification/domain/user_stats_model.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/time_block_provider.dart';
import 'package:life_os_productivity/features/focus/presentation/providers/focus_session_provider.dart';

final statsBoxProvider = Provider((ref) => Hive.box<UserStatsModel>('user_stats_box'));

// State class to bundle UserStats and Dynamic Today Score
class GamificationState {
  final UserStatsModel stats;
  final int todayScore;

  GamificationState(this.stats, this.todayScore);
}

class StatsNotifier extends Notifier<GamificationState> {
  @override
  GamificationState build() {
    final box = ref.watch(statsBoxProvider);
    var stats = box.get('currentUser');

    final today = DateTime.now();

    if (stats == null) {
      stats = UserStatsModel(lastActiveDate: today, currentStreak: 1, longestStreak: 1);
      box.put('currentUser', stats);
    } else {
      // Periksa apakah hari berganti untuk logic streak
      stats.checkAndUpdateStreak(today);
      stats.save();
    }

    // Kalkulasi Skor Hari Ini secara dinamis
    final score = _calculateTodayScore(today);

    // Save score of today to history map continuously
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    // Only update if it's potentially different to avoid infinite loops if not careful
    if (stats.dailyScores[dateKey] != score) {
      stats.dailyScores[dateKey] = score;
      stats.save();
    }

    return GamificationState(stats, score);
  }

  int _calculateTodayScore(DateTime today) {
    // ─── STRICT SCORING LOGIC ───
    // Every day starts at 0. You only get points by completing what you planned.

    // 1. Task Score (40%)
    final tasks = ref.watch(tasksByDateProvider(today));
    double taskScore = 0;
    if (tasks.isNotEmpty) {
      final completed = tasks.where((t) => t.isCompleted).length;
      taskScore = (completed / tasks.length) * 40;
    } else {
      // MODIFIED: If no tasks, score is 0, not 40.
      taskScore = 0; 
    }

    // 2. Planner Blocks Score (40%)
    final blocks = ref.watch(todayTimeBlocksProvider);
    double blockScore = 0;
    if (blocks.isNotEmpty) {
      final completed = blocks.where((b) => b.isCompleted).length;
      blockScore = (completed / blocks.length) * 40;
    } else {
      // MODIFIED: If no blocks, score is 0, not 40.
      blockScore = 0;
    }

    // 3. Focus Session (20%)
    final focusSessions = ref.watch(focusSessionsByDateProvider(today));
    // Reward for active focus: setidaknya 1 sesi fokus memberikan 20 poin.
    // Bisa ditingkatkan misal 20 poin per 1 jam fokus.
    double focusScore = focusSessions.isNotEmpty ? 20.0 : 0.0;

    final totalScore = (taskScore + blockScore + focusScore).clamp(0, 100).toInt();
    return totalScore;
  }
}

final gamificationProvider = NotifierProvider<StatsNotifier, GamificationState>(() {
  return StatsNotifier();
});
