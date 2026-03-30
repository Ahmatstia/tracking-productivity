import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/time_block_provider.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/habit_pattern_provider.dart';
import 'package:life_os_productivity/features/planner/presentation/widgets/daily_planner_widget.dart';
import 'package:life_os_productivity/features/tasks/presentation/widgets/task_card.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';
import 'package:life_os_productivity/features/gamification/presentation/providers/stats_provider.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return '🌙 Selamat Malam';
    if (hour < 11) return '☀️ Selamat Pagi';
    if (hour < 15) return '🌤️ Selamat Siang';
    if (hour < 19) return '🌇 Selamat Sore';
    return '🌙 Selamat Malam';
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMMEEEEd('id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final todayBlocks = ref.watch(todayTimeBlocksProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final unAppliedHabits = ref.watch(unAppliedHabitsProvider(_today));

    final gamification = ref.watch(gamificationProvider);
    final score = gamification.todayScore;
    final streak = gamification.stats.currentStreak;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Builder(
                            builder: (context) {
                              return IconButton(
                                icon: Icon(PhosphorIcons.list(), color: AppColors.textPrimary, size: 28),
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                                onPressed: () {
                                  ScaffoldState? outerScaffold = context.findRootAncestorStateOfType<ScaffoldState>();
                                  if (outerScaffold != null) {
                                    outerScaffold.openDrawer();
                                  } else {
                                    Scaffold.of(context).openDrawer();
                                  }
                                },
                              );
                            }
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _formatDate(_today),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (todayBlocks.isNotEmpty)
                                    IconButton(
                                      icon: Icon(PhosphorIcons.trash(), color: AppColors.error.withValues(alpha: 0.7), size: 16),
                                      onPressed: () => _confirmClearToday(),
                                      tooltip: 'Bersihkan Jadwal',
                                      padding: const EdgeInsets.only(left: 8),
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      _ScoreRing(score: score, streak: streak),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 12),

                  // Habit Auto-Complete Banner
                  if (unAppliedHabits.isNotEmpty)
                    _HabitSuggestionBanner(
                      count: unAppliedHabits.length,
                      onApply: () {
                        final blocks = generateBlocksFromHabits(unAppliedHabits, _today);
                        ref.read(timeBlockProvider.notifier).applyBlocksForDate(blocks);
                        for (final h in unAppliedHabits) {
                          ref.read(habitPatternProvider.notifier).markApplied(h.id);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ ${blocks.length} kebiasaan diterapkan ke hari ini!'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.1, end: 0),

                  // TabBar Container
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIcons.clock(), size: 14),
                              const SizedBox(width: 6),
                              Text('Jadwal (${todayBlocks.length})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIcons.tray(), size: 14),
                              const SizedBox(width: 6),
                              Text('Kotak Masuk (${todayTasks.length})'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab View (Planner vs Inbox Tasks) ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPlannerTab(todayBlocks.isEmpty),
                  _buildTasksTab(todayTasks),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlannerTab(bool isEmpty) {
    if (isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _EmptyPlannerState(),
          ],
        ),
      );
    }
    return DailyPlannerWidget(date: _today);
  }

  Widget _buildTasksTab(List tasks) {
    final carriedOver = tasks.where((t) => t.isCarriedOver == true).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (carriedOver.isNotEmpty) ...[
            Row(children: [
              Icon(PhosphorIcons.arrowUpRight(), size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              const Text(
                'Tugas Terlewat (Dari kemarin)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ]),
            const SizedBox(height: 8),
            ...carriedOver.map((t) => TaskCard(task: t)),
            const SizedBox(height: 16),
          ],
          if (tasks.isEmpty)
            const _EmptyTasksState()
          else
            ...tasks.map((t) => TaskCard(task: t)),
        ],
      ),
    );
  }

  void _confirmClearToday() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Bersihkan Jadwal?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Seluruh isi Planner untuk hari ini akan dihapus. Lanjutkan?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(timeBlockProvider.notifier).clearBlocksForDate(_today);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal hari ini dibersihkan')),
              );
            },
            child: const Text('Bersihkan Semua', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Supporting Widgets
// ─────────────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  final int score;
  final int streak;

  const _ScoreRing({required this.score, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text('$streak', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100.0,
                strokeWidth: 4,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(
                  score >= 80 ? AppColors.secondary : AppColors.primary,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HabitSuggestionBanner extends StatelessWidget {
  final int count;
  final VoidCallback onApply;

  const _HabitSuggestionBanner({required this.count, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.arrowsClockwise(), color: AppColors.secondary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔄 Kebiasaan Rutin Tersedia',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '$count kebiasaan belum diterapkan hari ini',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onApply,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'Terapkan',
              style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlannerState extends StatelessWidget {
  const _EmptyPlannerState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.calendarBlank(), size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text(
            'Jadwal Hari Ini Kosong',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Klik tombol + di tengah bawah untuk\nmerencanakan pekerjaan hari ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.checkCircle(), size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text(
            'Kotak Masuk Kosong',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tidak ada tugas lepas.\nSemua kegiatan sudah terjadwal rapi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
