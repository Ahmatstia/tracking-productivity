import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: GoogleFonts.spaceGrotesk(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              _formatDate(_today),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.syne(
                                color: AppColors.primary,
                                fontSize: 24, // Bigger for Syne aesthetic
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StreakBadge(streak: streak),
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

                  // Minimalist TabBar with More Menu
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          indicator: UnderlineTabIndicator(
                            borderSide: const BorderSide(
                              color: AppColors.textPrimary,
                              width: 2.5,
                            ),
                            insets: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                          ),
                          dividerColor: AppColors.border.withValues(alpha: 0.1),
                          labelColor: AppColors.textPrimary,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: GoogleFonts.syne(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: -0.5,
                          ),
                          unselectedLabelStyle: GoogleFonts.syne(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: -0.5,
                          ),
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(PhosphorIcons.clock(), size: 14),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'JADWAL (${todayBlocks.length})',
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(PhosphorIcons.tray(), size: 14),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'INBOX (${todayTasks.length})',
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (todayBlocks.isNotEmpty)
                        PopupMenuButton<String>(
                          icon: Icon(PhosphorIcons.dotsThreeVertical(), color: AppColors.textSecondary, size: 24),
                          position: PopupMenuPosition.under,
                          padding: EdgeInsets.zero,
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) {
                            if (value == 'clear') _confirmClearToday();
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'clear',
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.trash(), size: 18, color: AppColors.error),
                                  const SizedBox(width: 12),
                                  const Text('Bersihkan Hari Ini', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
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
                  DailyPlannerWidget(date: _today), // <── ALWAYS Direct Hour List
                  _buildTasksTab(todayTasks),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab(List tasks) {
    if (tasks.isEmpty) return const _EmptyTasksState();
    
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

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '$streak Hari',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
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

class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
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
      ),
    );
  }
}
