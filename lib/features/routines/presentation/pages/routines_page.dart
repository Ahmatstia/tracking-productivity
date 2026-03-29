import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/features/routines/presentation/providers/routine_provider.dart';
import 'package:life_os_productivity/features/routines/presentation/pages/edit_routine_page.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/time_block_provider.dart';

class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineProvider);
    final todayBlocks = ref.watch(todayTimeBlocksProvider);
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: const Text(
              'Habits & Routines',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: routines.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.repeat, size: 64, color: Colors.white.withValues(alpha: 0.1)),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum Ada Template Rutinitas',
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Klik + di bawah untuk membuat rutinitas baru\ndan terapkan ke jadwal harianmu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final routine = routines[index];
                      // Periksa apakah semua aktivitas dari rutinitas ini sudah ada di planner hari ini
                      final bool isAlreadyApplied = routine.blocks.isNotEmpty && 
                          routine.blocks.every((rb) => todayBlocks.any((tb) => tb.title == rb.title && tb.startTime == rb.startTime));

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(routine.colorCode).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(routine.colorCode).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    routine.name,
                                    style: TextStyle(
                                      color: Color(routine.colorCode),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(LucideIcons.edit2, color: Colors.white70, size: 18),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => EditRoutinePage(existingRoutine: routine)),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18),
                                      onPressed: () => ref.read(routineProvider.notifier).deleteRoutine(routine.id),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${routine.blocks.length} Aktivitas',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                if (routine.assignedDays.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(LucideIcons.calendarDays, color: Colors.white70, size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDays(routine.assignedDays),
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isAlreadyApplied ? null : () async {
                                  final replacedCount = await ref.read(routineProvider.notifier).applyRoutineToDate(routine.id, DateTime.now());
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          replacedCount > 0 
                                              ? '${routine.name} diterapkan! ($replacedCount jadwal lama dibersihkan)'
                                              : '${routine.name} berhasil diterapkan ke Hari Ini!'
                                        ),
                                        backgroundColor: replacedCount > 0 ? Colors.orangeAccent.withValues(alpha: 0.8) : null,
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(isAlreadyApplied ? LucideIcons.checkCheck : LucideIcons.checkCircle2, 
                                    color: isAlreadyApplied ? Colors.white54 : Colors.white, size: 16),
                                label: Text(isAlreadyApplied ? 'Sudah Terjadwal' : 'Terapkan ke Hari Ini', 
                                    style: TextStyle(color: isAlreadyApplied ? Colors.white54 : Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAlreadyApplied ? Colors.white.withValues(alpha: 0.1) : Color(routine.colorCode).withValues(alpha: 0.5),
                                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    childCount: routines.length,
                  ),
                ),
        ),
      ],
    );
  }

  String _formatDays(List<int> days) {
    if (days.isEmpty) return 'Tidak dijadwalkan';
    if (days.length == 7) return 'Setiap Hari';
    
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final sortedDays = List<int>.from(days)..sort();
    
    // Khusus Weekdays vs Weekend
    if (days.length == 5 && 
        days.contains(1) && days.contains(2) && days.contains(3) && days.contains(4) && days.contains(5)) {
      return 'Senin - Jumat';
    }
    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'Akhir Pekan';
    }

    return sortedDays.map((d) => dayNames[d - 1]).join(', ');
  }
}
