import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:life_os_productivity/features/planner/domain/time_block_model.dart';
import 'package:life_os_productivity/core/services/notification_service.dart';

final timeBlockBoxProvider =
    Provider((ref) => Hive.box<TimeBlockModel>('time_blocks_box'));

class TimeBlockNotifier extends StateNotifier<List<TimeBlockModel>> {
  final Box<TimeBlockModel> _box;

  TimeBlockNotifier(this._box) : super(_box.values.toList()) {
    // Reschedule all today's notification on startup
    NotificationService().rescheduleAllTodayNotifications(state);
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
    _box.put(block.id, block);
    NotificationService().scheduleTimeBlockNotification(block);
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
    _box.put(updated.id, updated);
    NotificationService().scheduleTimeBlockNotification(updated);
    _refresh();
  }

  // Apply a list of time blocks for a specific date (from habit auto-complete)
  void applyBlocksForDate(List<TimeBlockModel> blocks) {
    for (final block in blocks) {
      _box.put(block.id, block);
      NotificationService().scheduleTimeBlockNotification(block);
    }
    _refresh();
  }
}

final timeBlockProvider =
    StateNotifierProvider<TimeBlockNotifier, List<TimeBlockModel>>((ref) {
  final box = ref.watch(timeBlockBoxProvider);
  return TimeBlockNotifier(box);
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
