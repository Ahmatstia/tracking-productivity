import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/habit_pattern_provider.dart';

class ManageHabitsSheet extends ConsumerWidget {
  const ManageHabitsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitPatternProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.sheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Kelola Kebiasaan Harian',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Matikan saran atau hapus aktivitas yang sebelumnya Anda centang "Jadwal Kebiasaan".',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 20),

          // Habit List Content
          if (habits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Center(
                child: Text(
                  'Belum ada kebiasaan yang dibuat.',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: TextStyle(
                                  color: habit.isActive ? AppColors.textPrimary : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: habit.isActive ? null : TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(PhosphorIcons.clock(),
                                      size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    habit.startTime,
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        // Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: habit.isActive,
                              activeThumbColor: AppColors.textPrimary,
                              activeTrackColor: AppColors.textPrimary.withValues(alpha: 0.3),
                              onChanged: (val) {
                                ref.read(habitPatternProvider.notifier).togglePattern(habit.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(PhosphorIcons.trash(),
                                  color: AppColors.error, size: 20),
                              onPressed: () {
                                _confirmDeleteDialog(context, ref, habit.id, habit.title);
                              },
                              tooltip: 'Hapus Kebiasaan',
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDeleteDialog(
      BuildContext context, WidgetRef ref, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kebiasaan?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Apakah Anda yakin ingin menghapus kebiasaan "$title" secara permanen dari daftar pengingat harian?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(habitPatternProvider.notifier).deletePattern(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saran kebiasaan telah diputus permanen.')),
              );
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
