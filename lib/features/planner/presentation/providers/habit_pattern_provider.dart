import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:life_os_productivity/features/planner/domain/habit_pattern_model.dart';
import 'package:life_os_productivity/features/planner/domain/time_block_model.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/time_block_provider.dart';
import 'package:life_os_productivity/core/services/notification_service.dart';
import 'package:life_os_productivity/features/profile/presentation/providers/profile_provider.dart';
import 'package:life_os_productivity/features/profile/domain/user_profile_model.dart';

final habitPatternBoxProvider =
    Provider((ref) => Hive.box<HabitPatternModel>('habit_patterns_box'));

class HabitPatternNotifier extends StateNotifier<List<HabitPatternModel>> {
  final Box<HabitPatternModel> _box;
  final UserProfileModel _settings;

  HabitPatternNotifier(this._box, this._settings) : super(_box.values.toList());

  void _refresh() => state = _box.values.toList();

  void addPattern({
    required String title,
    required String startTime,
    required String endTime,
    String category = 'personal',
    List<int> daysOfWeek = const [],
    String? note,
  }) {
    final existing = _box.values.where((p) =>
        p.title.toLowerCase() == title.toLowerCase() &&
        p.startTime == startTime);

    if (existing.isNotEmpty) {
      final pattern = existing.first;
      pattern.occurrenceCount++;
      final today = DateTime.now().weekday;
      if (!pattern.daysOfWeek.contains(today)) {
        pattern.daysOfWeek = [...pattern.daysOfWeek, today];
      }
      _box.put(pattern.id, pattern); // Fix: use box.put instead of pattern.save()
    } else {
      final pattern = HabitPatternModel(
        id: const Uuid().v4(),
        title: title,
        startTime: startTime,
        endTime: endTime,
        category: category,
        daysOfWeek: daysOfWeek.isEmpty ? [DateTime.now().weekday] : daysOfWeek,
        occurrenceCount: 1,
        note: note,
      );
      _box.put(pattern.id, pattern);
      NotificationService().scheduleHabitReminder(pattern, settings: _settings);
    }
    _refresh();
  }

  void togglePattern(String id) {
    final p = _box.get(id);
    if (p != null) {
      p.isActive = !p.isActive;
      _box.put(id, p); // Fix: use box.put instead of p.save()
      if (p.isActive) {
        NotificationService().scheduleHabitReminder(p, settings: _settings);
      } else {
        NotificationService().cancelNotification(p.id);
      }
      _refresh();
    }
  }

  void deletePattern(String id) {
    _box.delete(id);
    NotificationService().cancelNotification(id);
    _refresh();
  }

  // Mark pattern as applied today (to avoid duplicate generation)
  void markApplied(String id) {
    final p = _box.get(id);
    if (p != null) {
      p.lastAppliedDate = DateTime.now();
      _box.put(id, p); // Fix: use box.put instead of p.save()
      _refresh();
    }
  }
}

final habitPatternProvider =
    StateNotifierProvider<HabitPatternNotifier, List<HabitPatternModel>>((ref) {
  final box = ref.watch(habitPatternBoxProvider);
  // Fix: use ref.read (not ref.watch) so provider is NOT recreated when profile changes
  final profile = ref.read(profileProvider);
  return HabitPatternNotifier(box, profile);
});

// Active habits for a specific day (weekday 1-7)
final habitsForDayProvider =
    Provider.family<List<HabitPatternModel>, int>((ref, weekday) {
  final patterns = ref.watch(habitPatternProvider);
  return patterns
      .where((p) => p.isActive && p.isActiveForDay(weekday))
      .toList();
});

// Check if there are habits not yet applied for a given date
final unAppliedHabitsProvider =
    Provider.family<List<HabitPatternModel>, DateTime>((ref, date) {
  final weekday = date.weekday;
  final patterns = ref.watch(habitsForDayProvider(weekday));
  final existingBlocks = ref.watch(timeBlocksByDateProvider(date));

  return patterns.where((pattern) {
    final alreadyApplied = existingBlocks.any((block) =>
        block.title.toLowerCase() == pattern.title.toLowerCase() &&
        block.startTime == pattern.startTime);
    return !alreadyApplied;
  }).toList();
});

// Generate TimeBlock list from habits for a target date (without saving)
List<TimeBlockModel> generateBlocksFromHabits(
    List<HabitPatternModel> habits, DateTime targetDate) {
  return habits.map((habit) {
    return TimeBlockModel(
      id: const Uuid().v4(),
      title: habit.title,
      startTime: habit.startTime,
      endTime: habit.endTime,
      category: habit.category,
      date: targetDate,
    );
  }).toList();
}
