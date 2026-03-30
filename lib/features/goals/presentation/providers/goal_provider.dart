import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/goal_model.dart';

final goalBoxProvider = Provider((ref) => Hive.box<GoalModel>('goals_box'));

class GoalNotifier extends StateNotifier<List<GoalModel>> {
  final Box<GoalModel> _box;

  // Mengambil data awal dari Hive saat aplikasi dibuka
  GoalNotifier(this._box) : super(_box.values.toList());

  void addGoal(GoalModel goal) {
    _box.add(goal);
    // SANGAT PENTING: Kita harus membuat List baru agar Riverpod tahu ada perubahan
    state = [..._box.values];
  }

  void updateGoal(int index, String title, String description, DateTime? targetDate) {
    final goal = _box.getAt(index);
    if (goal != null) {
      goal.title = title;
      goal.description = description;
      goal.targetDate = targetDate;
      goal.save();
      state = [..._box.values];
    }
  }

  void deleteGoal(int index) {
    _box.deleteAt(index);
    state = [..._box.values];
  }

  void addSubTask(int goalIndex, String subTaskTitle) {
    final goal = _box.getAt(goalIndex);
    if (goal != null) {
      goal.subTasks.add(SubTask(title: subTaskTitle));
      _recalculateProgress(goal);
      goal.save();
      state = [..._box.values];
    }
  }

  void toggleSubTask(int goalIndex, int subTaskIndex, bool isCompleted) {
    final goal = _box.getAt(goalIndex);
    if (goal != null) {
      goal.subTasks[subTaskIndex].isCompleted = isCompleted;
      _recalculateProgress(goal);
      goal.save();
      state = [..._box.values];
    }
  }

  void deleteSubTask(int goalIndex, int subTaskIndex) {
    final goal = _box.getAt(goalIndex);
    if (goal != null) {
      goal.subTasks.removeAt(subTaskIndex);
      _recalculateProgress(goal);
      goal.save();
      state = [..._box.values];
    }
  }

  void reorderSubTask(int goalIndex, int oldIndex, int newIndex) {
    final goal = _box.getAt(goalIndex);
    if (goal != null) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = goal.subTasks.removeAt(oldIndex);
      goal.subTasks.insert(newIndex, item);
      goal.save();
      state = [..._box.values];
    }
  }

  void _recalculateProgress(GoalModel goal) {
    if (goal.subTasks.isEmpty) {
      goal.progress = 0.0;
      goal.isCompleted = false;
      return;
    }
    
    int completedCount = goal.subTasks.where((st) => st.isCompleted).length;
    goal.progress = completedCount / goal.subTasks.length;
    goal.isCompleted = completedCount == goal.subTasks.length;
  }
}

final goalProvider =
    StateNotifierProvider<GoalNotifier, List<GoalModel>>((ref) {
  final box = ref.watch(goalBoxProvider);
  return GoalNotifier(box);
});
