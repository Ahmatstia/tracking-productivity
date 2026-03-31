import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:life_os_productivity/features/gamification/presentation/providers/stats_provider.dart';

class AnalyticsDashboardPage extends ConsumerWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(weeklyAnalyticsProvider);
    final gamification = ref.watch(gamificationProvider);
    final stats = gamification.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Header ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analitik Performa',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Ringkasan 7 hari terakhir'.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),

              const SizedBox(height: 32),

              // ── Top Stats Row ───────────────────────
              Row(
                children: [
                  _AnalyticsStatCard(
                    'Streak',
                    '${stats.currentStreak}',
                    PhosphorIcons.lightning(),
                  ),
                  _AnalyticsStatCard(
                    'Fokus',
                    '${analytics.totalFocusMinutes}m',
                    PhosphorIcons.timer(),
                  ),
                  _AnalyticsStatCard(
                    'Selesai',
                    '${analytics.tasksCompletedWeek}',
                    PhosphorIcons.checkCircle(),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 40),

              // ── Productivity Chart ──────────────────
              const _SectionLabel(label: 'PRODUKTIVITAS MINGGUAN'),
              const SizedBox(height: 16),
              _WeeklyBarChart(days: analytics.days),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Hari paling produktif adalah ${analytics.peakProductivityDay}',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic),
                ),
              ),

              const SizedBox(height: 40),

              // ── Average Score Section ──────────────
              _ScoreSummaryBanner(score: analytics.avgProductivityScore),

              const SizedBox(height: 40),

              // ── Heatmap ────────────────────────────
              const _SectionLabel(label: 'KONSISTENSI AKTIVITAS'),
              const SizedBox(height: 16),
              _ActivityHeatmap(dailyScores: stats.dailyScores),

              const SizedBox(height: 40),

              // ── Detailed Task Completion ───────────
              const _SectionLabel(label: 'TINGKAT PENYELESAIAN TUGAS'),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: analytics.days.reversed
                      .map((d) => _CompletionProgressRow(day: d))
                      .toList(),
                ),
              ),

              const SizedBox(height: 120), // Bottom padding for Nav
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-Widgets
// ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _AnalyticsStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _AnalyticsStatCard(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
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
    final dayNamesShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          final barHeight = (day.score / 100 * 120).clamp(6.0, 120.0);
          final label = dayNamesShort[day.date.weekday - 1];
          final isToday = day.date.day == DateTime.now().day;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${day.score}',
                  style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: 500.ms,
                curve: Curves.easeOutBack,
                width: 24,
                height: barHeight,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.w900 : FontWeight.normal,
                  color:
                      isToday ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ScoreSummaryBanner extends StatelessWidget {
  final double score;
  const _ScoreSummaryBanner({required this.score});

  @override
  Widget build(BuildContext context) {
    final rounded = score.round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Average Productivity',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$rounded%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  _getMotivation(rounded),
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          Icon(PhosphorIcons.chartLineUp(),
              color: Colors.white.withValues(alpha: 0.2), size: 64),
        ],
      ),
    );
  }

  String _getMotivation(int score) {
    if (score >= 80)
      return 'Luar biasa! Konsistensi Anda adalah kunci kesuksesan.';
    if (score >= 50) return 'Anda berada di jalur yang benar. Tetap semangat!';
    return 'Setiap hari adalah awal baru. Mari mulai lebih fokus hari ini.';
  }
}

class _ActivityHeatmap extends StatelessWidget {
  final Map<String, int> dailyScores;
  const _ActivityHeatmap({required this.dailyScores});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<Widget> cells = [];

    // Display last 70 days
    for (int i = 69; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final scoreCount = dailyScores[dateStr] ?? 0;

      // Mono scale opacity
      final opacity =
          scoreCount == 0 ? 0.05 : (scoreCount / 100).clamp(0.2, 1.0);

      cells.add(
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(children: cells),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Less',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 9)),
              const SizedBox(width: 6),
              ...List.generate(
                  4,
                  (i) => Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary
                              .withValues(alpha: (i + 1) * 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
              const SizedBox(width: 6),
              const Text('More',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionProgressRow extends StatelessWidget {
  final DayStats day;
  const _CompletionProgressRow({required this.day});

  @override
  Widget build(BuildContext context) {
    final dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    final label = dayNames[day.date.weekday - 1];
    final rate = day.completionRate;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Text('${day.tasksCompleted}/${day.totalTasks}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
              FractionallySizedBox(
                widthFactor: rate.isNaN ? 0 : rate,
                                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
