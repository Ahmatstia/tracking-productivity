import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:life_os_productivity/features/tasks/domain/task_model.dart';

final taskBoxProvider = Provider((ref) => Hive.box<TaskModel>('tasks_box'));

class TaskNotifier extends StateNotifier<List<TaskModel>> {
  final Box<TaskModel> _box;

  TaskNotifier(this._box) : super(_box.values.toList()) {
    _carryOverPastTasks();
  }

  void _refresh() => state = _box.values.toList();

  void addTask({
    required String title,
    String description = '',
    required DateTime date,
    String category = 'Tasks',
    String? startTime,
    String? endTime,
    int priority = 0,
  }) {
    final newTask = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      date: date,
      category: category,
      startTime: startTime,
      endTime: endTime,
      priority: priority,
    );
    _box.put(newTask.id, newTask);
    _refresh();
  }

  void toggleTask(String id) {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      _box.put(id, task); // Fix: use box.put instead of task.save()
      _refresh();
    }
  }

  void deleteTask(String id) {
    _box.delete(id);
    _refresh();
  }

  void updateTask(TaskModel updated) {
    _box.put(updated.id, updated);
    _refresh();
  }

  // Automatically carry over all unfinished past tasks to today
  void _carryOverPastTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool changed = false;

    for (final task in _box.values.toList()) {
      if (!task.isCompleted) {
        final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
        if (taskDate.isBefore(today)) {
          task.date = now;
          task.isCarriedOver = true;
          task.startTime = null;
          task.endTime = null;
          _box.put(task.id, task); // Fix: use box.put instead of task.save()
          changed = true;
        }
      }
    }
    if (changed) {
      _refresh();
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<TaskModel>>((ref) {
  final box = ref.watch(taskBoxProvider);
  return TaskNotifier(box);
});

// Filter tasks by date
final tasksByDateProvider =
    Provider.family<List<TaskModel>, DateTime>((ref, filterDate) {
  final tasks = ref.watch(taskProvider);
  final filtered = tasks.where((task) {
    return task.date.year == filterDate.year &&
        task.date.month == filterDate.month &&
        task.date.day == filterDate.day;
  }).toList();
  // Sort: urgent first, then important, then normal; incomplete first
  filtered.sort((a, b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }
    return b.priority.compareTo(a.priority);
  });
  return filtered;
});

// Today's tasks
final todayTasksProvider = Provider<List<TaskModel>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return ref.watch(tasksByDateProvider(today));
});

// Unscheduled tasks for today (no time assigned)
final unscheduledTodayTasksProvider = Provider<List<TaskModel>>((ref) {
  return ref.watch(todayTasksProvider).where((t) => !t.isScheduled).toList();
});
