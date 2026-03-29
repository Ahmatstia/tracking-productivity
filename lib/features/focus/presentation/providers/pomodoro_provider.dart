import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os_productivity/features/focus/presentation/providers/focus_session_provider.dart';

class PomodoroState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isFocusMode;
  final String? selectedTaskId;

  PomodoroState({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.isFocusMode,
    this.selectedTaskId,
  });

  PomodoroState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    bool? isFocusMode,
    String? selectedTaskId,
  }) {
    return PomodoroState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;
  final Ref _ref;

  PomodoroNotifier(this._ref)
      : super(PomodoroState(
          remainingSeconds: 1500, // 25 minutes
          totalSeconds: 1500,
          isRunning: false,
          isFocusMode: true,
        ));

  void selectTask(String? taskId) {
    if (!state.isRunning) {
      state = state.copyWith(selectedTaskId: taskId);
    }
  }

  void setCustomDuration(int minutes) {
    if (state.isRunning) return;
    state = state.copyWith(
      remainingSeconds: minutes * 60,
      totalSeconds: minutes * 60,
    );
  }

  void start() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _completeSession();
      }
    });
  }

  void _completeSession() {
    pause();
    // Record to database
    if (state.isFocusMode) {
      _ref.read(focusSessionProvider.notifier).logSession(
            taskId: state.selectedTaskId,
            date: DateTime.now(),
            durationSeconds: state.totalSeconds,
            isFocusMode: true,
          );
      // Pindahkan ke mode break
      switchMode();
    } else {
      // Kembali ke mode fokus
      switchMode();
    }
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    pause();
    state = state.copyWith(
      remainingSeconds: state.totalSeconds,
      isRunning: false,
    );
  }

  void switchMode() {
    pause();
    final newIsFocusMode = !state.isFocusMode;
    final newSeconds = newIsFocusMode ? 1500 : 300;
    state = state.copyWith(
      isFocusMode: newIsFocusMode,
      remainingSeconds: newSeconds,
      totalSeconds: newSeconds,
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
  return PomodoroNotifier(ref);
});
