import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:life_os_productivity/features/tasks/domain/task_model.dart';

final taskBoxProvider = Provider((ref) => Hive.box<TaskModel>('tasks_box'));

class TaskNotifier extends StateNotifier<List<TaskModel>> {
  final Box<TaskModel> _box;

  TaskNotifier(this._box) : super(_box.values.toList());

  void addTask({
    required String title,
    String description = '',
    required DateTime date,
    String category = 'Tasks',
  }) {
    final newTask = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      date: date,
      category: category,
    );
    _box.put(newTask.id, newTask);
    state = [..._box.values];
  }

  void toggleTask(String id) {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
      state = [..._box.values];
    }
  }

  void deleteTask(String id) {
    _box.delete(id);
    state = [..._box.values];
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<TaskModel>>((ref) {
  final box = ref.watch(taskBoxProvider);
  return TaskNotifier(box);
});

// Family Provider to filter tasks by a specific date (e.g., Today)
final tasksByDateProvider = Provider.family<List<TaskModel>, DateTime>((ref, filterDate) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) {
    return task.date.year == filterDate.year &&
           task.date.month == filterDate.month &&
           task.date.day == filterDate.day;
  }).toList();
});
