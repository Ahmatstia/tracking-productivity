import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/dashboard/presentation/providers/nav_provider.dart';
import 'package:life_os_productivity/features/goals/presentation/providers/goal_provider.dart';
import 'package:life_os_productivity/features/goals/presentation/widgets/goal_card.dart';
import 'package:life_os_productivity/features/goals/presentation/widgets/add_goal_sheet.dart';
import 'package:life_os_productivity/features/goals/presentation/pages/goal_detail_page.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';
import 'package:life_os_productivity/features/planner/presentation/pages/today_page.dart';
import 'package:life_os_productivity/features/planner/presentation/widgets/add_time_block_sheet.dart';
import 'package:life_os_productivity/features/routines/presentation/pages/routines_page.dart';
import 'package:life_os_productivity/features/routines/presentation/pages/edit_routine_page.dart';
import 'package:life_os_productivity/features/analytics/presentation/pages/analytics_dashboard_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:life_os_productivity/features/dashboard/presentation/widgets/app_drawer.dart';

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final goals = ref.watch(goalProvider);
    final today = DateTime.now();

    final List<Widget> pages = [
      // ── Tab 0: Today (Smart Daily Planner + Tasks) ──
      const TodayPage(),

      // ── Tab 1: Routines ──
      const RoutinesPage(),

      // ── Tab 2: Goals ──
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Impian Besar Saya",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Text(
                "Pantau mimpi & target hidupmu",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: goals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.target(), size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            const Text("Belum ada mimpi.", style: TextStyle(color: AppColors.textSecondary)),
                            const Text("Gunakan tombol + untuk menambah!", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GoalDetailPage(goalIndex: index),
                              ),
                            ),
                            child: GoalCard(
                              title: goal.title,
                              progress: goal.progress,
                              timeLeft: goal.targetDate == null
                                  ? "Mimpi Tanpa Batas Waktu"
                                  : "Target: ${DateFormat('dd/MM/yyyy').format(goal.targetDate!)}",
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // ── Tab 3: Analytics ──
      const AnalyticsDashboardPage(),
    ];

    // Safety fallback in case old cached navIndex is 4
    final safeIndex = currentIndex >= pages.length ? pages.length - 1 : currentIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: pages[safeIndex],
      floatingActionButton: _buildFAB(context, ref, today),
      bottomNavigationBar: _buildNavBar(ref, safeIndex),
    );
  }

  Widget _buildFAB(BuildContext context, WidgetRef ref, DateTime today) {
    return FloatingActionButton(
      onPressed: () => _showSuperFABSheet(context, ref, today),
      backgroundColor: AppColors.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Icon(PhosphorIcons.plus(), color: Colors.white, size: 28),
    );
  }

  void _showSuperFABSheet(BuildContext context, WidgetRef ref, DateTime today) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(top: 24, bottom: 40),
        decoration: const BoxDecoration(
          color: AppColors.sheetBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Apa yang ingin Anda buat?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            
            _SuperFABOption(
              icon: PhosphorIcons.checkSquareOffset(),
              title: 'Tugas Baru (Kotak Masuk)',
              subtitle: 'Tambahkan tugas lepas tanpa jadwal',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _TaskAddSheet(date: today),
                );
              },
            ),
            _SuperFABOption(
              icon: PhosphorIcons.clock(),
              title: 'Jadwal Aktivitas Planner',
              subtitle: 'Blok waktu di kalender Hari Ini',
              color: AppColors.secondary, // Charcoal
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddTimeBlockSheet(date: today),
                );
              },
            ),
            _SuperFABOption(
              icon: PhosphorIcons.arrowsClockwise(),
              title: 'Template Rutinitas',
              subtitle: 'Buat paket aktivitas yang berulang',
              color: AppColors.textSecondary, // Medium Grey
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditRoutinePage()));
              },
            ),
            _SuperFABOption(
              icon: PhosphorIcons.target(),
              title: 'Mimpi / Target',
              subtitle: 'Buat capaian jangka panjang',
              color: AppColors.primaryAccent, // Dark Grey Accent
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddGoalSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(WidgetRef ref, int safeIndex) {
    return CurvedNavigationBar(
      index: safeIndex,
      backgroundColor: AppColors.background,
      color: AppColors.navBar,
      buttonBackgroundColor: AppColors.primary,
      animationDuration: const Duration(milliseconds: 300),
      onTap: (index) => ref.read(navIndexProvider.notifier).state = index,
      items: [
        Icon(PhosphorIcons.calendarBlank(), color: safeIndex == 0 ? Colors.white : AppColors.textSecondary, size: 26),
        Icon(PhosphorIcons.arrowsClockwise(), color: safeIndex == 1 ? Colors.white : AppColors.textSecondary, size: 26),
        Icon(PhosphorIcons.target(), color: safeIndex == 2 ? Colors.white : AppColors.textSecondary, size: 26),
        Icon(PhosphorIcons.chartBar(), color: safeIndex == 3 ? Colors.white : AppColors.textSecondary, size: 26),
      ],
    );
  }
}

class _SuperFABOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SuperFABOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(), color: AppColors.border, size: 20),
          ],
        ),
      ),
    );
  }
}

// Lightweight task add sheet for Inbox (from Tasks)
class _TaskAddSheet extends ConsumerStatefulWidget {
  final DateTime date;
  const _TaskAddSheet({required this.date});

  @override
  ConsumerState<_TaskAddSheet> createState() => _TaskAddSheetState();
}

class _TaskAddSheetState extends ConsumerState<_TaskAddSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _priority = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.sheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text('Tugas Kotak Masuk (Tanpa Jadwal)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Apa yang ingin dikerjakan?',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 2,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Deskripsi (opsional)',
              hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [0, 1, 2].map((p) {
              final labels = ['Normal', '⭐ Penting', '🔴 Urgent'];
              final colors = [AppColors.textSecondary, AppColors.primary, AppColors.error];
              final isSelected = _priority == p;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? colors[p].withValues(alpha: 0.12) : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? colors[p] : AppColors.border),
                    ),
                    child: Text(labels[p],
                        style: TextStyle(
                            color: isSelected ? colors[p] : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isEmpty) return;
                ref.read(taskProvider.notifier).addTask(
                  title: title,
                  description: _descController.text.trim(),
                  date: widget.date,
                  priority: _priority,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Simpan di Kotak Masuk',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
