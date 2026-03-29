import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/goals/presentation/providers/goal_provider.dart';

class GoalDetailPage extends ConsumerStatefulWidget {
  final int goalIndex;

  const GoalDetailPage({
    super.key,
    required this.goalIndex,
  });

  @override
  ConsumerState<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends ConsumerState<GoalDetailPage> {
  final TextEditingController _subTaskController = TextEditingController();

  @override
  void dispose() {
    _subTaskController.dispose();
    super.dispose();
  }

  void _showAddSubTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text("Tambah Sub-Task", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _subTaskController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Contoh: Menabung 1 juta",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = _subTaskController.text.trim();
                if (text.isNotEmpty) {
                  ref.read(goalProvider.notifier).addSubTask(widget.goalIndex, text);
                  _subTaskController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: const Text("Simpan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteGoal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text("Hapus Mimpi?", style: TextStyle(color: Colors.white)),
          content: const Text("Apakah kamu yakin ingin menghapus mimpi ini? Data tidak dapat dikembalikan.", style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(goalProvider.notifier).deleteGoal(widget.goalIndex);
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close Detail page
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalProvider);

    // Safety check just in case goal was deleted and list rebuilt
    if (widget.goalIndex >= goals.length) {
      return const Scaffold(body: Center(child: Text("Mimpi tidak ditemukan")));
    }

    final goal = goals[widget.goalIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Detail Mimpi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.red),
            onPressed: _confirmDeleteGoal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(goal.title,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(goal.description,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 15),
            Text("Target: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}",
                style: const TextStyle(color: AppColors.secondary, fontSize: 14)),
            const SizedBox(height: 30),

            // Progress Bar Section
            Text("Progress (${(goal.progress * 100).toInt()}%)",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearPercentIndicator(
              lineHeight: 12.0,
              percent: goal.progress,
              padding: EdgeInsets.zero,
              barRadius: const Radius.circular(10),
              backgroundColor: Colors.grey[800],
              progressColor: AppColors.secondary,
              animation: true,
              animateFromLastPercent: true,
            ),
            const SizedBox(height: 30),

            // Sub-Tasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sub-Tasks / Milestone",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _showAddSubTaskDialog,
                  icon: const Icon(LucideIcons.plusCircle, color: AppColors.secondary),
                )
              ],
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: goal.subTasks.isEmpty
                  ? const Center(child: Text("Belum ada milestone. Tambahkan sekarang!", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: goal.subTasks.length,
                      itemBuilder: (context, index) {
                        final subtask = goal.subTasks[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: subtask.isCompleted,
                              activeColor: AppColors.secondary,
                              checkColor: Colors.black,
                              onChanged: (val) {
                                if (val != null) {
                                  ref.read(goalProvider.notifier).toggleSubTask(widget.goalIndex, index, val);
                                }
                              },
                            ),
                            title: Text(
                              subtask.title,
                              style: TextStyle(
                                color: Colors.white,
                                decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: Colors.grey,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.grey, size: 20),
                              onPressed: () {
                                ref.read(goalProvider.notifier).deleteSubTask(widget.goalIndex, index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
