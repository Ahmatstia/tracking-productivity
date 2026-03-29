import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:life_os_productivity/features/routines/domain/routine_template_model.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/time_block_provider.dart';

final routineBoxProvider = Provider((ref) => Hive.box<RoutineTemplateModel>('routine_templates_box'));

class RoutineNotifier extends StateNotifier<List<RoutineTemplateModel>> {
  final Box<RoutineTemplateModel> _box;
  final Ref _ref;

  RoutineNotifier(this._box, this._ref) : super(_box.values.toList());

  void _refresh() => state = _box.values.toList();

  void addRoutine({
    required String name,
    required List<RoutineBlockModel> blocks,
    List<int> assignedDays = const [],
    int colorCode = 0xFF007BFF,
  }) {
    final routine = RoutineTemplateModel(
      id: const Uuid().v4(),
      name: name,
      blocks: blocks,
      assignedDays: assignedDays,
      colorCode: colorCode,
    );
    _box.put(routine.id, routine);
    _refresh();
  }

  void updateRoutine(RoutineTemplateModel routine) {
    _box.put(routine.id, routine);
    _refresh();
  }

  void deleteRoutine(String id) {
    _box.delete(id);
    _refresh();
  }

  /// Applikasikan Routine ini pada hari tertentu (otomatis buat TimeBlock ke planner)
  Future<int> applyRoutineToDate(String routineId, DateTime date) async {
    final routine = _box.get(routineId);
    if (routine == null) return 0;

    int replacedCount = 0;
    final notifier = _ref.read(timeBlockProvider.notifier);

    for (final block in routine.blocks) {
      // 1. Calculate the time range in minutes
      final startParts = block.startTime.split(':');
      final endParts = block.endTime.split(':');
      final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      // 2. Clean up any existing blocks that overlap with this slot
      replacedCount += notifier.deleteOverlappingBlocks(date, startMin, endMin);

      // 3. Add the new habit block
      notifier.addBlock(
        title: block.title,
        startTime: block.startTime,
        endTime: block.endTime,
        category: block.category,
        date: date,
      );
    }
    return replacedCount;
  }
}

final routineProvider = StateNotifierProvider<RoutineNotifier, List<RoutineTemplateModel>>((ref) {
  final box = ref.watch(routineBoxProvider);
  return RoutineNotifier(box, ref);
});
