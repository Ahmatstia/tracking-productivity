import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/tasks/domain/task_model.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final TaskModel task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted ? AppColors.secondary.withValues(alpha: 0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: () {
            ref.read(taskProvider.notifier).toggleTask(task.id);
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? AppColors.secondary : Colors.grey,
                width: 2,
              ),
              color: task.isCompleted ? AppColors.secondary : Colors.transparent,
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.black)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.isCompleted ? Colors.grey : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  task.description,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.grey.withValues(alpha: 0.5) : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
          onPressed: () {
            ref.read(taskProvider.notifier).deleteTask(task.id);
          },
        ),
      ),
    );
  }
}
