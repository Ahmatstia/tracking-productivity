import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:life_os_productivity/core/services/notification_service.dart';
import 'package:life_os_productivity/features/profile/presentation/providers/profile_provider.dart';
import '../../domain/goal_model.dart';

final goalBoxProvider = Provider((ref) => Hive.box<GoalModel>('goals_box'));

class GoalNotifier extends StateNotifier<List<GoalModel>> {
  final Box<GoalModel> _box;
  final Ref _ref;

  GoalNotifier(this._box, this._ref) : super(_box.values.toList());

  void _refresh() => state = [..._box.values];

  void addGoal(GoalModel goal) {
    _box.add(goal);
    _scheduleReminder(goal);
    _refresh();
  }

  void updateGoal(int index, String title, String description, DateTime? targetDate) {
    final goal = _box.getAt(index);
    if (goal != null) {
      goal.title = title;
      goal.description = description;
      goal.targetDate = targetDate;
      _box.putAt(index, goal); // Fix: use box.putAt instead of goal.save()
      _scheduleReminder(goal);
      _refresh();
    }
  }

  void deleteGoal(int index) {
    final goal = _box.getAt(index);
    if (goal != null) {
      // Use stable string ID for notification cancellation
      NotificationService().cancelNotification('goal_${goal.key}');
      _box.deleteAt(index);
    }
    _refresh();
  }

  void addSubTask(int goalIndex, String subTaskTitle) {
    final goal = _box.getAt(goalIndex);
    if (goal != null) {
      goal.subTasks.add(SubTask(title: subTaskTitle));
      _recalculateProgress(goal);
      _box.putAt(goalIndex, goal); // Fix: use box.putAt instead of goal.save()
      _refresh();
    }
  }

  void toggleSubTask(int goalIndex, int subTaskIndex, bool isCompleted) {
    final goal = _box.getAt(goalIndex);
    if (goal != null) {
      goal.subTasks[subTaskIndex].isCompleted = isCompleted;
      _recalculateProgress(goal);
      _box.putAt(goalIndex, goal); // Fix: use box.putAt instead of goal.save()
      _refresh();
    }
  }

  void deleteSubTask(int goalIndex, int subTaskIndex) {
    final goal = _box.getAt(goalIndex);
    if (goal != null) {
      goal.subTasks.removeAt(subTaskIndex);
      _recalculateProgress(goal);
      _box.putAt(goalIndex, goal); // Fix: use box.putAt instead of goal.save()
      _refresh();
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
      _box.putAt(goalIndex, goal); // Fix: use box.putAt instead of goal.save()
      _refresh();
    }
  }

  void _scheduleReminder(GoalModel goal) {
    final settings = _ref.read(profileProvider);
    // Use a stable string key that won't collide with other goals
    final notifId = 'goal_${goal.key}';
    if (goal.targetDate != null && !goal.isCompleted) {
      NotificationService().scheduleGoalReminder(
        goalId: notifId,
        title: goal.title,
        deadline: goal.targetDate!,
        settings: settings,
      );
    } else {
      NotificationService().cancelNotification(notifId);
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
    final wasCompleted = goal.isCompleted;
    goal.isCompleted = completedCount == goal.subTasks.length;

    // Reschedule/Cancel reminder based on completion change
    if (wasCompleted != goal.isCompleted) {
      _scheduleReminder(goal);
    }
  }
}

final goalProvider =
    StateNotifierProvider<GoalNotifier, List<GoalModel>>((ref) {
  final box = ref.watch(goalBoxProvider);
  return GoalNotifier(box, ref);
});
