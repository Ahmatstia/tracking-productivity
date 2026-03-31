import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/routines/presentation/providers/routine_provider.dart';
import 'package:life_os_productivity/features/routines/presentation/pages/edit_routine_page.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/time_block_provider.dart';
import 'package:life_os_productivity/features/routines/presentation/widgets/manage_habits_sheet.dart';

class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineProvider);
    final todayBlocks = ref.watch(todayTimeBlocksProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (Static) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rutinitas',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const ManageHabitsSheet(),
                      );
                    },
                    icon: Icon(PhosphorIcons.faders(), size: 14),
                    label: const Text('Kelola Kebiasaan', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),

            // Section Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'DAFTAR RUTINITAS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: routines.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(), // Prevent bounce scroll when empty
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.arrowsClockwise(), size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Rutinitas',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Klik + di bawah untuk membuat rutinitas baru\ndan terapkan ke jadwal harianmu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: routines.length,
                      itemBuilder: (context, index) {
                        final routine = routines[index];
                        final bool isAlreadyApplied = routine.blocks.isNotEmpty && 
                            routine.blocks.every((rb) => todayBlocks.any((tb) => tb.title == rb.title && tb.startTime == rb.startTime));

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cardShadow.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: AppColors.textPrimary,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            routine.name,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(PhosphorIcons.pencilSimple(), color: AppColors.textSecondary.withValues(alpha: 0.5), size: 18),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => EditRoutinePage(existingRoutine: routine)),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(PhosphorIcons.trash(), color: AppColors.error.withValues(alpha: 0.6), size: 18),
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
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  if (routine.assignedDays.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.inputFill,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(PhosphorIcons.calendarBlank(), color: AppColors.textSecondary, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDays(routine.assignedDays),
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
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
                                          backgroundColor: replacedCount > 0 ? AppColors.textSecondaryAccent.withValues(alpha: 0.8) : null,
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(isAlreadyApplied ? PhosphorIcons.checks() : PhosphorIcons.checkCircle(), 
                                      color: isAlreadyApplied ? AppColors.textSecondary : Colors.white, size: 16),
                                  label: Text(isAlreadyApplied ? 'Sudah Terjadwal' : 'Terapkan ke Hari Ini', 
                                      style: TextStyle(color: isAlreadyApplied ? AppColors.textSecondary : Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAlreadyApplied ? AppColors.inputFill : AppColors.textPrimary,
                                    foregroundColor: isAlreadyApplied ? AppColors.textSecondary : (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white),
                                    disabledBackgroundColor: AppColors.inputFill,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDays(List<int> days) {
    if (days.isEmpty) return 'Tidak dijadwalkan';
    if (days.length == 7) return 'Setiap Hari';
    
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final sortedDays = List<int>.from(days)..sort();
    
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
