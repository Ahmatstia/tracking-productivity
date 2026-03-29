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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Tambah Sub-Task", style: TextStyle(color: AppColors.textPrimary)),
          content: TextField(
            controller: _subTaskController,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: "Contoh: Menabung 1 juta",
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: AppColors.textSecondary)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Hapus Mimpi?", style: TextStyle(color: AppColors.textPrimary)),
          content: const Text("Apakah kamu yakin ingin menghapus mimpi ini? Data tidak dapat dikembalikan.", style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(goalProvider.notifier).deleteGoal(widget.goalIndex);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, elevation: 0),
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

    if (widget.goalIndex >= goals.length) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text("Mimpi tidak ditemukan", style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final goal = goals[widget.goalIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Detail Mimpi", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.trash2, color: AppColors.error.withValues(alpha: 0.7)),
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
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(goal.description,
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 15),
            Text("Target: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}",
                style: const TextStyle(color: AppColors.secondary, fontSize: 14)),
            const SizedBox(height: 30),

            // Progress Bar Section
            Text("Progress (${(goal.progress * 100).toInt()}%)",
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearPercentIndicator(
              lineHeight: 12.0,
              percent: goal.progress,
              padding: EdgeInsets.zero,
              barRadius: const Radius.circular(10),
              backgroundColor: AppColors.border,
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
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _showAddSubTaskDialog,
                  icon: const Icon(LucideIcons.plusCircle, color: AppColors.secondary),
                )
              ],
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: goal.subTasks.isEmpty
                  ? const Center(child: Text("Belum ada milestone. Tambahkan sekarang!", style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      itemCount: goal.subTasks.length,
                      itemBuilder: (context, index) {
                        final subtask = goal.subTasks[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cardShadow.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: subtask.isCompleted,
                              activeColor: AppColors.secondary,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                if (val != null) {
                                  ref.read(goalProvider.notifier).toggleSubTask(widget.goalIndex, index, val);
                                }
                              },
                            ),
                            title: Text(
                              subtask.title,
                              style: TextStyle(
                                color: subtask.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                                decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: AppColors.textSecondary,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(LucideIcons.x, color: AppColors.textSecondary.withValues(alpha: 0.4), size: 20),
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
