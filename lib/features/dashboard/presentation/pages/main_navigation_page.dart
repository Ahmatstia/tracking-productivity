import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/features/dashboard/presentation/providers/nav_provider.dart';
import 'package:life_os_productivity/features/goals/presentation/providers/goal_provider.dart';
import 'package:life_os_productivity/features/goals/presentation/widgets/goal_card.dart';
import 'package:life_os_productivity/features/goals/presentation/widgets/add_goal_sheet.dart';
import 'package:life_os_productivity/features/goals/presentation/pages/goal_detail_page.dart';
import 'package:life_os_productivity/features/tasks/presentation/widgets/add_task_sheet.dart';

import 'package:life_os_productivity/features/tasks/presentation/pages/tasks_page.dart';
import 'package:life_os_productivity/features/focus/presentation/pages/focus_page.dart';

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    // Membaca data mimpi asli dari database Hive melalui Provider
    final goals = ref.watch(goalProvider);

    final List<Widget> pages = [
      const Center(child: Text('Dashboard')),
      const TasksPage(),

      // HALAMAN GOALS (DATA ASLI)
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("My Big Dreams",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Text("Data disimpan secara permanen di HP kamu",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              Expanded(
                  child: goals.isEmpty
                    ? const Center(
                        child: Text("Belum ada mimpi. Klik + untuk menambah!"))
                    : ListView.builder(
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GoalDetailPage(goalIndex: index),
                                ),
                              );
                            },
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
      const FocusPage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      floatingActionButton: (currentIndex == 1 || currentIndex == 2)
          ? FloatingActionButton(
              onPressed: () {
                if (currentIndex == 1) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddTaskSheet(),
                  );
                } else if (currentIndex == 2) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddGoalSheet(),
                  );
                }
              },
              backgroundColor: const Color(0xFF00D084),
              child: const Icon(LucideIcons.plus, color: Colors.black),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            ref.read(navIndexProvider.notifier).state = index,
        indicatorColor: const Color(0xFF007BFF).withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard), label: 'Home'),
          NavigationDestination(
              icon: Icon(LucideIcons.checkSquare), label: 'Tasks'),
          NavigationDestination(icon: Icon(LucideIcons.target), label: 'Goals'),
          NavigationDestination(icon: Icon(LucideIcons.timer), label: 'Focus'),
        ],
      ),
    );
  }
}
