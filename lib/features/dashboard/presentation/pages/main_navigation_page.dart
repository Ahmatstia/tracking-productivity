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
import 'package:life_os_productivity/features/focus/presentation/pages/focus_page.dart';
import 'package:life_os_productivity/features/planner/presentation/pages/today_page.dart';
import 'package:life_os_productivity/features/routines/presentation/pages/routines_page.dart';
import 'package:life_os_productivity/features/routines/presentation/widgets/add_routine_sheet.dart';
import 'package:life_os_productivity/features/analytics/presentation/pages/analytics_dashboard_page.dart';


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
                "My Big Dreams",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                "Pantau mimpi & target hidupmu",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: goals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.target, size: 64, color: Colors.white.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            const Text("Belum ada mimpi.", style: TextStyle(color: Colors.white54)),
                            const Text("Klik + untuk menambah!", style: TextStyle(color: Colors.white38, fontSize: 13)),
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

      // ── Tab 4: Focus ──
      const FocusPage(),

      // ── Tab 5: Analytics ──
      const AnalyticsDashboardPage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      floatingActionButton: _buildFAB(context, ref, currentIndex, today),
      bottomNavigationBar: _buildNavBar(ref, currentIndex),
    );
  }

  Widget? _buildFAB(BuildContext context, WidgetRef ref, int index, DateTime today) {
    // TodayPage manages its own FAB, so hide global FAB for tab 0
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
        child: const Icon(LucideIcons.plus, color: Colors.black),
      );
    }
    if (index == 2) {
      return FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddRoutineSheet(),
        ),
        backgroundColor: AppColors.secondary,
        child: const Icon(LucideIcons.plus, color: Colors.black),
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
        child: const Icon(LucideIcons.plus, color: Colors.black),
      );
    }
    return null;
  }

  Widget _buildNavBar(WidgetRef ref, int currentIndex) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => ref.read(navIndexProvider.notifier).state = index,
      backgroundColor: const Color(0xFF161626),
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      destinations: const [
        NavigationDestination(
          icon: Icon(LucideIcons.calendarDays),
          label: 'Hari Ini',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.checkSquare),
          label: 'Tasks',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.repeat),
          label: 'Routines',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.target),
          label: 'Goals',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.timer),
          label: 'Focus',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.barChart2),
          label: 'Analytics',
        ),
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
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text('Tambah Tugas Baru',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Apa yang ingin dikerjakan?',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Deskripsi (opsional)',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [0, 1, 2].map((p) {
              final labels = ['Normal', '⭐ Penting', '🔴 Urgent'];
              final colors = [Colors.white38, const Color(0xFFFFD93D), const Color(0xFFFF6B6B)];
              final isSelected = _priority == p;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? colors[p].withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? colors[p] : Colors.white12),
                    ),
                    child: Text(labels[p],
                        style: TextStyle(
                            color: isSelected ? colors[p] : Colors.white38,
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
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Simpan Tugas',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
