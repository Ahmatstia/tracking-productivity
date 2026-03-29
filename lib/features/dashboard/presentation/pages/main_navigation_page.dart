import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/dashboard/presentation/providers/nav_provider.dart';
import 'package:life_os_productivity/features/goals/presentation/providers/goal_provider.dart';
import 'package:life_os_productivity/features/goals/presentation/widgets/goal_card.dart';
import 'package:life_os_productivity/features/goals/presentation/widgets/add_goal_sheet.dart';
import 'package:life_os_productivity/features/goals/presentation/pages/goal_detail_page.dart';
import 'package:life_os_productivity/features/tasks/presentation/pages/tasks_page.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';
import 'package:life_os_productivity/features/planner/presentation/pages/today_page.dart';
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

      // ── Tab 1: Tasks (full list view) ──
      const TasksPage(),

      // ── Tab 2: Routines ──
      const RoutinesPage(),

      // ── Tab 3: Goals ──
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
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: goals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.target, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            const Text("Belum ada mimpi.", style: TextStyle(color: AppColors.textSecondary)),
                            const Text("Klik + untuk menambah!", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                              timeLeft:
                                  "Target: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}",
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // ── Tab 4: Analytics ──
      const AnalyticsDashboardPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: pages[currentIndex],
      floatingActionButton: _buildFAB(context, ref, currentIndex, today),
      bottomNavigationBar: _buildNavBar(ref, currentIndex),
    );
  }

  Widget? _buildFAB(BuildContext context, WidgetRef ref, int index, DateTime today) {
    if (index == 0) return null;
    if (index == 1) {
      return FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _TaskAddSheet(date: today),
        ),
        backgroundColor: AppColors.secondary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      );
    }
    if (index == 2) {
      return FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditRoutinePage()),
        ),
        backgroundColor: AppColors.secondary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      );
    }
    if (index == 3) {
      return FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddGoalSheet(),
        ),
        backgroundColor: AppColors.secondary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      );
    }
    return null;
  }

  Widget _buildNavBar(WidgetRef ref, int currentIndex) {
    final safeIndex = currentIndex > 4 ? 4 : currentIndex;
    
    return CurvedNavigationBar(
      index: safeIndex,
      backgroundColor: AppColors.background,
      color: AppColors.navBar,
      buttonBackgroundColor: AppColors.primary,
      animationDuration: const Duration(milliseconds: 300),
      onTap: (index) => ref.read(navIndexProvider.notifier).state = index,
      items: [
        Icon(LucideIcons.calendarDays, color: safeIndex == 0 ? Colors.white : AppColors.textSecondary, size: 26),
        Icon(LucideIcons.checkSquare, color: safeIndex == 1 ? Colors.white : AppColors.textSecondary, size: 26),
        Icon(LucideIcons.repeat, color: safeIndex == 2 ? Colors.white : AppColors.textSecondary, size: 26),
        Icon(LucideIcons.target, color: safeIndex == 3 ? Colors.white : AppColors.textSecondary, size: 26),
        Icon(LucideIcons.barChart2, color: safeIndex == 4 ? Colors.white : AppColors.textSecondary, size: 26),
      ],
    );
  }
}

// Lightweight task add sheet for Tasks tab FAB
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
          const Text('Tambah Tugas Baru',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
              final colors = [AppColors.textSecondary, const Color(0xFFE67E22), const Color(0xFFE17055)];
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
              child: const Text('Simpan Tugas',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
