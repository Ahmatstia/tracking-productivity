import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/tasks/domain/task_model.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  static const _priorityColors = [AppColors.textSecondary, AppColors.primary, AppColors.error];
  static const _priorityLabels = ['', 'Penting', 'Urgent'];
  static final _priorityIcons = [null, PhosphorIcons.star(), PhosphorIcons.warningCircle()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = _priorityColors[task.priority.clamp(0, 2)];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.border
              : task.priority > 0
                  ? priorityColor.withValues(alpha: 0.3)
                  : AppColors.border,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 24,
            spreadRadius: 2,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: GestureDetector(
          onTap: () => ref.read(taskProvider.notifier).toggleTask(task.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? AppColors.secondary : AppColors.textSecondary.withValues(alpha: 0.4),
                width: 2,
              ),
              color: task.isCompleted ? AppColors.secondary : Colors.transparent,
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  color: task.isCompleted ? AppColors.textSecondary.withValues(alpha: 0.5) : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),
            if (task.priority > 0 && !task.isCompleted) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_priorityIcons[task.priority.clamp(0, 2)],
                        size: 10, color: priorityColor),
                    const SizedBox(width: 3),
                    Text(
                      _priorityLabels[task.priority.clamp(0, 2)],
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  task.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: task.isCompleted ? AppColors.textSecondary.withValues(alpha: 0.3) : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            if (task.isScheduled)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.clock(), size: 11, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${task.startTime} - ${task.endTime}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (task.isCarriedOver)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.arrowUpRight(), size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    const Text(
                      'Dibawa dari kemarin',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(PhosphorIcons.trash(), color: AppColors.error.withValues(alpha: 0.6), size: 18),
          onPressed: () => ref.read(taskProvider.notifier).deleteTask(task.id),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}
