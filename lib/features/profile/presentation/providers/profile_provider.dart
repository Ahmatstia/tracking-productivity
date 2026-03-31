import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:life_os_productivity/features/profile/domain/user_profile_model.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfileModel>((ref) {
  final box = Hive.box<UserProfileModel>('user_profile_box');
  // Initialize with default if empty
  if (box.isEmpty) {
    box.add(UserProfileModel());
  }
  return ProfileNotifier(box);
});

class ProfileNotifier extends StateNotifier<UserProfileModel> {
  ProfileNotifier(Box<UserProfileModel> box) : super(box.values.first);

  void updateName(String newName) {
    state.name = newName;
    state.save();
    state = _clone(state);
  }

  void updateAvatar(int index) {
    state.avatarIndex = index;
    state.save();
    state = _clone(state);
  }

  void updateNotifications(bool enabled) {
    state.notificationsEnabled = enabled;
    state.save();
    state = _clone(state);
  }

  void updatePlannerReminders(bool enabled) {
    state.plannerReminders = enabled;
    state.save();
    state = _clone(state);
  }

  void updateHabitReminders(bool enabled) {
    state.habitReminders = enabled;
    state.save();
    state = _clone(state);
  }

  void updateGoalReminders(bool enabled) {
    state.goalReminders = enabled;
    state.save();
    state = _clone(state);
  }

  void updateFocusAlerts(bool enabled) {
    state.focusAlerts = enabled;
    state.save();
    state = _clone(state);
  }

  void updateSounds(bool enabled) {
    state.soundsEnabled = enabled;
    state.save();
    state = _clone(state);
  }

  void updateGlobalSound(String? path) {
    state.globalSoundPath = path;
    state.save();
    state = _clone(state);
  }

  void updatePlannerSound(String? path) {
    state.plannerSoundPath = path;
    state.save();
    state = _clone(state);
  }

  void updateHabitSound(String? path) {
    state.habitSoundPath = path;
    state.save();
    state = _clone(state);
  }

  void updateFocusSound(String? path) {
    state.focusSoundPath = path;
    state.save();
    state = _clone(state);
  }

  // Helper to trigger UI rebuild
  UserProfileModel _clone(UserProfileModel original) {
    return UserProfileModel(
      name: original.name,
      avatarIndex: original.avatarIndex,
      avatarPath: original.avatarPath,
      notificationsEnabled: original.notificationsEnabled,
      plannerReminders: original.plannerReminders,
      habitReminders: original.habitReminders,
      goalReminders: original.goalReminders,
      focusAlerts: original.focusAlerts,
      soundsEnabled: original.soundsEnabled,
      globalSoundPath: original.globalSoundPath,
      plannerSoundPath: original.plannerSoundPath,
      habitSoundPath: original.habitSoundPath,
      focusSoundPath: original.focusSoundPath,
    );
  }
}
