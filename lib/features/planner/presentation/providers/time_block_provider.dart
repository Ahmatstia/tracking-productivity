import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:life_os_productivity/features/planner/domain/time_block_model.dart';
import 'package:life_os_productivity/features/planner/domain/habit_pattern_model.dart';
import 'package:life_os_productivity/features/profile/domain/user_profile_model.dart';
import 'package:life_os_productivity/core/services/notification_service.dart';
import 'package:life_os_productivity/features/profile/presentation/providers/profile_provider.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/habit_pattern_provider.dart';

final timeBlockBoxProvider =
    Provider((ref) => Hive.box<TimeBlockModel>('time_blocks_box'));

class TimeBlockNotifier extends StateNotifier<List<TimeBlockModel>> {
  final Box<TimeBlockModel> _box;
  final UserProfileModel _settings;

  TimeBlockNotifier(this._box, List<HabitPatternModel> habits, this._settings) : super(_box.values.toList()) {
    // Reschedule all today's notification on startup
    NotificationService().rescheduleAllTodayNotifications(
      blocks: state,
      habits: habits,
      settings: _settings,
    );
  }

  void _refresh() => state = _box.values.toList();

  void addBlock({
    required String title,
    required String startTime,
    required String endTime,
    String category = 'personal',
    required DateTime date,
    String? linkedTaskId,
    String? note,
  }) {
    final block = TimeBlockModel(
      id: const Uuid().v4(),
      title: title,
      startTime: startTime,
      endTime: endTime,
      category: category,
      date: date,
      linkedTaskId: linkedTaskId,
      note: note,
    );

    // ── Exclusive Scheduling: Overwrite overlaps before adding ──
    deleteOverlappingBlocks(date, block.startMinutes, block.endMinutes);

    _box.put(block.id, block);
    NotificationService().scheduleTimeBlockNotification(block, settings: _settings);
    _refresh();
  }

  void toggleBlock(String id) {
    final block = _box.get(id);
    if (block != null) {
      block.isCompleted = !block.isCompleted;
      block.save();
      _refresh();
    }
  }

  void deleteBlock(String id) {
    _box.delete(id);
    NotificationService().cancelNotification(id);
    _refresh();
  }

  void updateBlock(TimeBlockModel updated) {
    // ── Exclusive Scheduling: Overwrite overlaps when updating ──
    // Exclude the ID being updated to prevent self-deletion
    deleteOverlappingBlocks(updated.date, updated.startMinutes, updated.endMinutes, excludeId: updated.id);

    _box.put(updated.id, updated);
    NotificationService().scheduleTimeBlockNotification(updated, settings: _settings);
    _refresh();
  }

  // Apply a list of time blocks for a specific date (from habit auto-complete)
  void applyBlocksForDate(List<TimeBlockModel> blocks) {
    for (final block in blocks) {
      // ── Exclusive Scheduling: Habit overwrites manual ──
      deleteOverlappingBlocks(block.date, block.startMinutes, block.endMinutes);
      
      _box.put(block.id, block);
      NotificationService().scheduleTimeBlockNotification(block, settings: _settings);
    }
    _refresh();
  }

  /// Delete existing blocks on a specific date that overlap with the given time range
  int deleteOverlappingBlocks(DateTime date, int startMin, int endMin, {String? excludeId}) {
    final overlaps = _box.values.where((b) {
      if (excludeId != null && b.id == excludeId) return false;

      final isSameDate = b.date.year == date.year &&
          b.date.month == date.month &&
          b.date.day == date.day;
      if (!isSameDate) return false;
      
      // Overlap logic: (start1 < end2 && end1 > start2)
      return (b.startMinutes < endMin && b.endMinutes > startMin);
    }).toList();

    for (final block in overlaps) {
      _box.delete(block.id);
      NotificationService().cancelNotification(block.id);
    }
    
    // No direct refresh here if part of a bigger transaction, 
    // but the final caller will call _refresh()
    return overlaps.length;
  }

  /// Delete all blocks for a specific date
  void clearBlocksForDate(DateTime date) {
    final blocks = _box.values.where((b) {
      return b.date.year == date.year &&
          b.date.month == date.month &&
          b.date.day == date.day;
    }).toList();

    for (final block in blocks) {
      _box.delete(block.id);
      NotificationService().cancelNotification(block.id);
    }
    
    if (blocks.isNotEmpty) _refresh();
  }
}

final timeBlockProvider =
    StateNotifierProvider<TimeBlockNotifier, List<TimeBlockModel>>((ref) {
  final box = ref.watch(timeBlockBoxProvider);
  final habits = ref.watch(habitPatternProvider);
  final profile = ref.watch(profileProvider);
  return TimeBlockNotifier(box, habits, profile);
});

// Filter blocks by a specific date
final timeBlocksByDateProvider =
    Provider.family<List<TimeBlockModel>, DateTime>((ref, date) {
  final blocks = ref.watch(timeBlockProvider);
  return blocks
      .where((b) =>
          b.date.year == date.year &&
          b.date.month == date.month &&
          b.date.day == date.day)
      .toList()
    ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
});

// Today's blocks in sorted order
final todayTimeBlocksProvider = Provider<List<TimeBlockModel>>((ref) {
  final today = DateTime.now();
  return ref.watch(timeBlocksByDateProvider(today));
});
