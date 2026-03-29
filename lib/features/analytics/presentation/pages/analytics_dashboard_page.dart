import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:life_os_productivity/features/analytics/presentation/pages/daily_review_page.dart';
import 'package:life_os_productivity/features/gamification/domain/user_stats_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AnalyticsDashboardPage extends ConsumerWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(weeklyAnalyticsProvider);
    final statsBox = Hive.box<UserStatsModel>('user_stats_box');
    final userStats = statsBox.isNotEmpty ? statsBox.getAt(0) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Analitik Hidup',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        )),
                    Text('7 hari terakhir',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        )),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DailyReviewPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.clipboardText(), color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Review Hari Ini',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Stats Row ───────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: PhosphorIcons.flame(),
                    value: '${userStats?.currentStreak ?? 0}',
                    label: 'Streak Hari',
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: PhosphorIcons.timer(),
                    value: '${analytics.totalFocusMinutes}m',
                    label: 'Fokus Minggu',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: PhosphorIcons.checkCircle(),
                    value: '${analytics.tasksCompletedWeek}',
                    label: 'Task Selesai',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Productivity Score Chart ─────────────
            const _SectionTitle('📊 Produktivitas Mingguan'),
            const SizedBox(height: 12),
            _WeeklyBarChart(days: analytics.days),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '⚡ Paling produktif hari ${analytics.peakProductivityDay}',
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),

            // ── Average Score Banner ─────────────────
            _AvgScoreBanner(score: analytics.avgProductivityScore),
            const SizedBox(height: 24),

            // ── Heatmap ──────────────────────────────
            const _SectionTitle('🔥 Heatmap Aktivitas'),
            const SizedBox(height: 12),
            _ActivityHeatmap(dailyScores: analytics.dailyScores),
            const SizedBox(height: 24),

            // ── Task Completion Rate ─────────────────
            const _SectionTitle('✅ Tingkat Penyelesaian Task'),
            const SizedBox(height: 12),
            ...(analytics.days.map((d) => _DayCompletionRow(day: d))),
            const SizedBox(height: 24),

            // ── Focus Distribution ───────────────────
            const _SectionTitle('⏱️ Distribusi Fokus Mingguan'),
            const SizedBox(height: 12),
            _FocusDistributionChart(days: analytics.days),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<DayStats> days;
  const _WeeklyBarChart({required this.days});

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) {
          final h = (d.score / 100 * 120).clamp(4.0, 120.0);
          final color = d.score >= 70
              ? AppColors.primary
              : d.score >= 40
                  ? AppColors.textSecondary
                  : AppColors.error;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${d.score}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 28,
                height: h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [color.withValues(alpha: 0.3), color],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(dayLabels[d.date.weekday - 1],
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _AvgScoreBanner extends StatelessWidget {
  final double score;
  const _AvgScoreBanner({required this.score});

  @override
  Widget build(BuildContext context) {
    final rounded = score.round();
    final emoji = rounded >= 70 ? '🔥' : rounded >= 40 ? '💪' : '😴';
    final msg = rounded >= 70
        ? 'Minggu yang luar biasa!'
        : rounded >= 40
            ? 'Lumayan, masih bisa ditingkatkan!'
            : 'Yuk lebih semangat minggu ini!';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.accent.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rata-rata Score Minggu Ini',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text('$rounded / 100',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    )),
                Text(msg,
                    style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityHeatmap extends StatelessWidget {
  final Map<String, int> dailyScores;
  const _ActivityHeatmap({required this.dailyScores});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cells = <Widget>[];
    for (int i = 69; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final score = dailyScores[key] ?? 0;
      final opacity = score == 0 ? 0.06 : (score / 100).clamp(0.15, 1.0);
      cells.add(
        Tooltip(
          message: '$key: $score pts',
          child: Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(children: cells),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Lebih sedikit', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              const SizedBox(width: 6),
              ...List.generate(5, (i) => Container(
                    width: 12, height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: (i + 1) * 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
              const SizedBox(width: 6),
              const Text('Lebih banyak', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCompletionRow extends StatelessWidget {
  final DayStats day;
  const _DayCompletionRow({required this.day});

  @override
  Widget build(BuildContext context) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final label = days[day.date.weekday - 1];
    final rate = day.completionRate;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: rate,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('${day.tasksCompleted}/${day.totalTasks}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _FocusDistributionChart extends StatelessWidget {
  final List<DayStats> days;
  const _FocusDistributionChart({required this.days});

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final maxMin = days.fold<int>(1, (m, d) => d.focusMinutes > m ? d.focusMinutes : m);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: days.map((d) {
          final pct = d.focusMinutes / maxMin;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(dayLabels[d.date.weekday - 1],
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
                Expanded(
                  child: Stack(children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct.isNaN ? 0 : pct,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 10),
                Text('${d.focusMinutes}m',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
