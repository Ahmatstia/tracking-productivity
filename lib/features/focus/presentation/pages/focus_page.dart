import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/focus/presentation/providers/pomodoro_provider.dart';

class FocusPage extends ConsumerWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    final minutes = (pomodoro.remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (pomodoro.remainingSeconds % 60).toString().padLeft(2, '0');

    // Progress for circular indicator
    final total = pomodoro.isFocusMode ? 1500 : 300;
    final progress = pomodoro.remainingSeconds / total;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pomodoro.isFocusMode ? "Focus Time" : "Break Time",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            pomodoro.isFocusMode ? "Concentrate on your goals" : "Take a short rest",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 50),

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
                  backgroundColor: Colors.grey[800],
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
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: LucideIcons.refreshCcw,
                onPressed: () => notifier.reset(),
                color: Colors.grey,
              ),
              const SizedBox(width: 30),
              _ControlButton(
                icon: pomodoro.isRunning ? LucideIcons.pause : LucideIcons.play,
                isLarge: true,
                onPressed: () => pomodoro.isRunning ? notifier.pause() : notifier.start(),
                backgroundColor: pomodoro.isFocusMode ? AppColors.primary : AppColors.secondary,
                color: Colors.black,
              ),
              const SizedBox(width: 30),
              _ControlButton(
                icon: LucideIcons.skipForward,
                onPressed: () => notifier.switchMode(),
                color: Colors.grey,
              ),
            ],
          ),
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
          color: backgroundColor ?? Colors.grey[900],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: isLarge ? 32 : 24),
      ),
    );
  }
}
