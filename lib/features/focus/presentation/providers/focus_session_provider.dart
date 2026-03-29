import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:life_os_productivity/features/focus/domain/focus_session_model.dart';

final focusSessionBoxProvider = Provider((ref) => Hive.box<FocusSessionModel>('focus_session_box'));

class FocusSessionNotifier extends StateNotifier<List<FocusSessionModel>> {
  final Box<FocusSessionModel> _box;

  FocusSessionNotifier(this._box) : super(_box.values.toList());

  void _refresh() => state = _box.values.toList();

  void logSession({
    String? taskId,
    required DateTime date,
    required int durationSeconds,
    bool isFocusMode = true,
  }) {
    // Hanya simpan log jika durasinya lebih dari 1 menit (mencegah spam restart)
    if (durationSeconds > 60) {
      final session = FocusSessionModel(
        id: const Uuid().v4(),
        taskId: taskId,
        date: date,
        durationSeconds: durationSeconds,
        isFocusMode: isFocusMode,
      );
      _box.put(session.id, session);
      _refresh();
    }
  }

  void deleteSession(String id) {
    _box.delete(id);
    _refresh();
  }
}

final focusSessionProvider =
    StateNotifierProvider<FocusSessionNotifier, List<FocusSessionModel>>((ref) {
  final box = ref.watch(focusSessionBoxProvider);
  return FocusSessionNotifier(box);
});

final focusSessionsByDateProvider =
    Provider.family<List<FocusSessionModel>, DateTime>((ref, filterDate) {
  final sessions = ref.watch(focusSessionProvider);
  return sessions.where((s) =>
      s.isFocusMode && // Hanya hitung fokus kerja, bukan break
      s.date.year == filterDate.year &&
      s.date.month == filterDate.month &&
      s.date.day == filterDate.day).toList();
});
