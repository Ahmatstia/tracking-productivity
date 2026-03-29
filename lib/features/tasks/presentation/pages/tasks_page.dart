import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';
import 'package:life_os_productivity/features/tasks/presentation/widgets/task_card.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  int _filterPriority = -1; // -1 = semua
  bool _showCompleted = true;

  static const _priorityFilters = [
    {'label': 'Semua', 'value': -1, 'color': Colors.white54},
    {'label': '🔴 Urgent', 'value': 2, 'color': Color(0xFFFF6B6B)},
    {'label': '⭐ Penting', 'value': 1, 'color': Color(0xFFFFD93D)},
    {'label': 'Normal', 'value': 0, 'color': Colors.white38},
  ];

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tasksToday = ref.watch(tasksByDateProvider(today));

    // Apply filters
    final filtered = tasksToday.where((t) {
      final priorityMatch = _filterPriority == -1 || t.priority == _filterPriority;
      final completedMatch = _showCompleted || !t.isCompleted;
      return priorityMatch && completedMatch;
    }).toList();

    // Stats
    final totalCount = tasksToday.length;
    final completedCount = tasksToday.where((t) => t.isCompleted).length;
    final urgentCount = tasksToday.where((t) => t.priority == 2 && !t.isCompleted).length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Tasks",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _formatDate(today),
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    // Progress badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        "$completedCount/$totalCount Selesai",
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // Progress bar
                if (totalCount > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(
                            progress >= 1.0 ? AppColors.secondary : AppColors.primary,
                          ),
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (urgentCount > 0)
                        Row(
                          children: [
                            const Icon(LucideIcons.alertCircle, size: 12, color: Color(0xFFFF6B6B)),
                            const SizedBox(width: 4),
                            Text(
                              '$urgentCount tugas urgent belum selesai',
                              style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 11),
                            ),
                          ],
                        ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 16),

                // Filter row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._priorityFilters.map((f) {
                        final isSelected = _filterPriority == f['value'];
                        final color = f['color'] as Color;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _filterPriority = f['value'] as int),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? color : Colors.white12,
                                  width: 1.3,
                                ),
                              ),
                              child: Text(
                                f['label'] as String,
                                style: TextStyle(
                                  color: isSelected ? color : Colors.white38,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      // Hide/show completed toggle
                      GestureDetector(
                        onTap: () => setState(() => _showCompleted = !_showCompleted),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _showCompleted
                                ? Colors.white.withValues(alpha: 0.05)
                                : AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _showCompleted ? Colors.white12 : AppColors.secondary,
                              width: 1.3,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showCompleted ? LucideIcons.eye : LucideIcons.eyeOff,
                                size: 12,
                                color: _showCompleted ? Colors.white38 : AppColors.secondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Selesai',
                                style: TextStyle(
                                  color: _showCompleted ? Colors.white38 : AppColors.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Task list ──
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(totalCount)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return TaskCard(task: filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(int totalCount) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_filterPriority != -1 || !_showCompleted) ...[
            Icon(LucideIcons.filterX, size: 56, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada tugas yang cocok',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _filterPriority = -1;
                _showCompleted = true;
              }),
              child: const Text('Reset Filter', style: TextStyle(color: AppColors.primary)),
            ),
          ] else ...[
            Icon(LucideIcons.checkCircle2, size: 64, color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: 16),
            const Text(
              'Belum ada tugas hari ini',
              style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gunakan tab "Hari Ini" untuk menambah\ntugas dengan jadwal waktu',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
