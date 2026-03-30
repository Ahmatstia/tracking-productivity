import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:intl/intl.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/goals/presentation/providers/goal_provider.dart';
import 'package:life_os_productivity/features/goals/presentation/widgets/edit_goal_sheet.dart';

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
          title: const Text("Tambah Milestone Roadmap", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Pecah mimpimu menjadi langkah-langkah kecil yang bisa dieksekusi.", 
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: _subTaskController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "Contoh: Menabung 1 juta pertama",
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
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
                backgroundColor: AppColors.primary,
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
          content: const Text("Apakah kamu yakin ingin menghapus mimpi ini? Semua progres roadmap akan hilang.", style: TextStyle(color: AppColors.textSecondary)),
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
              child: const Text("Hapus Permanen", style: TextStyle(color: Colors.white)),
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
    final targetText = goal.targetDate == null 
        ? "Mimpi Tanpa Batas Waktu" 
        : "Target: ${DateFormat('dd MMMM yyyy', 'id_ID').format(goal.targetDate!)}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Roadmap Mimpi", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.pencilSimple(), color: AppColors.textPrimary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => EditGoalSheet(goal: goal, index: widget.goalIndex),
              );
            },
          ),
          IconButton(
            icon: Icon(PhosphorIcons.trash(), color: AppColors.error.withValues(alpha: 0.7)),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(targetText,
                          style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                _ProgressCircle(progress: goal.progress),
              ],
            ),
            const SizedBox(height: 16),
            if (goal.description.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("FILOSOFI / DETAIL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(goal.description, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5)),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Roadmap Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ROADMAP EKSEKUSI", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
                    Text("${goal.subTasks.where((s) => s.isCompleted).length} dari ${goal.subTasks.length} milestone selesai", 
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                GestureDetector(
                  onTap: _showAddSubTaskDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                    child: Icon(PhosphorIcons.plus(), color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: goal.subTasks.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.mapTrifold(), size: 48, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        const Text("Mimpi besar dimulai dari langkah kecil.\nBuat roadmap pertamamu!", 
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ))
                  : ReorderableListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: goal.subTasks.length,
                      onReorder: (oldIndex, newIndex) {
                        ref.read(goalProvider.notifier).reorderSubTask(widget.goalIndex, oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final subtask = goal.subTasks[index];
                        final isFirst = index == 0;
                        final isLast = index == goal.subTasks.length - 1;

                        return IntrinsicHeight(
                          key: ValueKey("roadmap_item_${subtask.title}"),
                          child: Row(
                            children: [
                              // Timeline UI
                              Column(
                                children: [
                                  Container(
                                    width: 2,
                                    height: 20,
                                    color: isFirst ? Colors.transparent : AppColors.border,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: subtask.isCompleted ? AppColors.secondary : AppColors.border, width: 2),
                                      color: subtask.isCompleted ? AppColors.secondary : Colors.transparent,
                                    ),
                                    child: Icon(
                                      subtask.isCompleted ? Icons.check : Icons.circle, 
                                      size: 12, 
                                      color: subtask.isCompleted ? Colors.white : AppColors.border
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: isLast ? Colors.transparent : AppColors.border,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Content Card
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: subtask.isCompleted ? AppColors.secondary.withValues(alpha: 0.2) : AppColors.border),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Drag Handle
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Icon(PhosphorIcons.dotsSixVertical(), size: 20, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => ref.read(goalProvider.notifier).toggleSubTask(widget.goalIndex, index, !subtask.isCompleted),
                                          child: Text(
                                            subtask.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: subtask.isCompleted ? FontWeight.normal : FontWeight.bold,
                                              color: subtask.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                                              decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(PhosphorIcons.trash(), size: 16, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                                        onPressed: () => ref.read(goalProvider.notifier).deleteSubTask(widget.goalIndex, index),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

class _ProgressCircle extends StatelessWidget {
  final double progress;
  const _ProgressCircle({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 54, height: 54,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(progress == 1.0 ? AppColors.secondary : AppColors.primary),
            ),
          ),
          Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
