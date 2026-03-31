import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/focus/presentation/providers/pomodoro_provider.dart';
import 'package:life_os_productivity/features/tasks/presentation/providers/task_provider.dart';
import 'package:life_os_productivity/features/focus/presentation/providers/focus_session_provider.dart';

class FocusPage extends ConsumerWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    final minutes = (pomodoro.remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (pomodoro.remainingSeconds % 60).toString().padLeft(2, '0');

    final total = pomodoro.totalSeconds;
    final progress = pomodoro.remainingSeconds / total;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
            Text(
              pomodoro.isFocusMode ? "Fokus" : "Istirahat",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              pomodoro.isFocusMode ? "Konsentrasi pada tujuan kamu" : "Istirahat sejenak",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 30),

            if (pomodoro.isFocusMode)
              const _TaskSelector(),

            const SizedBox(height: 40),

            // Timer Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pomodoro.isFocusMode ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                ),
                Text(
                  "$minutes:$seconds",
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: PhosphorIcons.arrowsClockwise(),
                  onPressed: () => notifier.reset(),
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 30),
                _ControlButton(
                  icon: pomodoro.isRunning ? PhosphorIcons.pause() : PhosphorIcons.play(),
                  isLarge: true,
                  onPressed: () => pomodoro.isRunning ? notifier.pause() : notifier.start(),
                  backgroundColor: pomodoro.isFocusMode ? AppColors.primary : AppColors.secondary,
                  color: Colors.white,
                ),
                const SizedBox(width: 30),
                _ControlButton(
                  icon: PhosphorIcons.skipForward(),
                  onPressed: () => notifier.switchMode(),
                  color: AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 40),
            const _FocusHistory(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ));
  }
}

class _TaskSelector extends ConsumerWidget {
  const _TaskSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final tasks = ref.watch(tasksByDateProvider(DateTime.now()));
    final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
    
    final selectedTask = pomodoro.selectedTaskId != null 
        ? tasks.where((t) => t.id == pomodoro.selectedTaskId).firstOrNull 
        : null;

    return GestureDetector(
      onTap: () {
        if (pomodoro.isRunning) return;
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.sheetBackground,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Pilih Task untuk Difokuskan', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  if (incompleteTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Tidak ada task hari ini yang tersisa!', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ...incompleteTasks.map((t) => ListTile(
                      title: Text(t.title, style: const TextStyle(color: AppColors.textPrimary)),
                      leading: Icon(PhosphorIcons.circle(), color: AppColors.textSecondary),
                      onTap: () {
                        ref.read(pomodoroProvider.notifier).selectTask(t.id);
                        Navigator.pop(context);
                      },
                    )),
                  ListTile(
                    title: const Text('Tanpa Task Khusus (Fokus Bebas)', style: TextStyle(color: AppColors.textSecondary)),
                    leading: Icon(PhosphorIcons.xCircle(), color: AppColors.textSecondary),
                    onTap: () {
                      ref.read(pomodoroProvider.notifier).selectTask(null);
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            );
          }
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.target(), size: 16, color: selectedTask != null ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                selectedTask?.title ?? "Pilih Task...",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selectedTask != null ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: selectedTask != null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusHistory extends ConsumerWidget {
  const _FocusHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(focusSessionsByDateProvider(DateTime.now()));
    
    if (sessions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Belum ada sesi fokus hari ini.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final totalSeconds = sessions.fold(0, (sum, s) => sum + s.durationSeconds);
    final totalMinutes = (totalSeconds / 60).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hari Ini', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              Text('$totalMinutes menit total', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...sessions.map((s) {
            final tasks = ref.read(taskProvider);
            final taskTitle = s.taskId != null 
                ? tasks.where((t) => t.id == s.taskId).firstOrNull?.title ?? "Deleted Task"
                : "Fokus Bebas";
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(PhosphorIcons.checkCircle(), size: 14, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(taskTitle, style: const TextStyle(color: AppColors.textPrimary)),
                  ),
                  Text('${(s.durationSeconds / 60).round()}m', style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color color;
  final bool isLarge;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.inputFill,
          shape: BoxShape.circle,
          border: backgroundColor == null ? Border.all(color: AppColors.border) : null,
          boxShadow: isLarge ? [
            BoxShadow(
              color: (backgroundColor ?? AppColors.primary).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ] : null,
        ),
        child: Icon(icon, color: color, size: isLarge ? 32 : 24),
      ),
    );
  }
}
