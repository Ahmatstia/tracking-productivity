import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PomodoroState {
  final int remainingSeconds;
  final bool isRunning;
  final bool isFocusMode;

  PomodoroState({
    required this.remainingSeconds,
    required this.isRunning,
    required this.isFocusMode,
  });

  PomodoroState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    bool? isFocusMode,
  }) {
    return PomodoroState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isFocusMode: isFocusMode ?? this.isFocusMode,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;

  PomodoroNotifier()
      : super(PomodoroState(
          remainingSeconds: 1500, // 25 minutes
          isRunning: false,
          isFocusMode: true,
        ));

  void start() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        pause();
        // Automatically switch mode or notify could happen here
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    pause();
    state = state.copyWith(
      remainingSeconds: state.isFocusMode ? 1500 : 300,
      isRunning: false,
    );
  }

  void switchMode() {
    pause();
    final newIsFocusMode = !state.isFocusMode;
    state = state.copyWith(
      isFocusMode: newIsFocusMode,
      remainingSeconds: newIsFocusMode ? 1500 : 300,
      isRunning: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  return PomodoroNotifier();
});
