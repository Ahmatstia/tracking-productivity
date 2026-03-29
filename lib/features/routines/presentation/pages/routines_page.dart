import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/features/routines/presentation/providers/routine_provider.dart';

class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineProvider);
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
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18),
                                  onPressed: () => ref.read(routineProvider.notifier).deleteRoutine(routine.id),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${routine.blocks.length} Aktivitas',
                              style: const TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ref.read(routineProvider.notifier).applyRoutineToDate(routine.id, DateTime.now());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${routine.name} berhasil diterapkan ke Hari Ini!')),
                                  );
                                },
                                icon: const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 16),
                                label: const Text('Terapkan ke Hari Ini', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(routine.colorCode).withValues(alpha: 0.5),
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
}
