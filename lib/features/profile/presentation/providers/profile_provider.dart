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
  final Box<UserProfileModel> _box;

  ProfileNotifier(this._box) : super(_box.getAt(0)!);

  /// Saves to Hive directly and notifies listeners.
  /// Uses _box.putAt(0, state) instead of state.save() to avoid
  /// HiveError: "This object is currently not in a box".
  void _save() {
    _box.putAt(0, state);
  }

  void updateName(String newName) {
    state = UserProfileModel(
      name: newName,
      avatarIndex: state.avatarIndex,
      avatarPath: state.avatarPath,
      notificationsEnabled: state.notificationsEnabled,
      plannerReminders: state.plannerReminders,
      habitReminders: state.habitReminders,
      goalReminders: state.goalReminders,
      focusAlerts: state.focusAlerts,
      soundsEnabled: state.soundsEnabled,
      globalSoundPath: state.globalSoundPath,
      plannerSoundPath: state.plannerSoundPath,
      habitSoundPath: state.habitSoundPath,
      focusSoundPath: state.focusSoundPath,
      coverImagePath: state.coverImagePath,
    );
    _save();
  }

  void updateAvatar(int index) {
    state = _copyWith(avatarIndex: index);
    _save();
  }

  void updateAvatarPath(String? path) {
    state = _copyWith(avatarPath: path, clearAvatarPath: path == null);
    _save();
  }

  void updateNotifications(bool enabled) {
    state = _copyWith(notificationsEnabled: enabled);
    _save();
  }

  void updatePlannerReminders(bool enabled) {
    state = _copyWith(plannerReminders: enabled);
    _save();
  }

  void updateHabitReminders(bool enabled) {
    state = _copyWith(habitReminders: enabled);
    _save();
  }

  void updateGoalReminders(bool enabled) {
    state = _copyWith(goalReminders: enabled);
    _save();
  }

  void updateFocusAlerts(bool enabled) {
    state = _copyWith(focusAlerts: enabled);
    _save();
  }

  void updateSounds(bool enabled) {
    state = _copyWith(soundsEnabled: enabled);
    _save();
  }

  void updateGlobalSound(String? path) {
    state = _copyWith(globalSoundPath: path, clearGlobalSound: path == null);
    _save();
  }

  void updatePlannerSound(String? path) {
    state = _copyWith(plannerSoundPath: path, clearPlannerSound: path == null);
    _save();
  }

  void updateHabitSound(String? path) {
    state = _copyWith(habitSoundPath: path, clearHabitSound: path == null);
    _save();
  }

  void updateFocusSound(String? path) {
    state = _copyWith(focusSoundPath: path, clearFocusSound: path == null);
    _save();
  }

  void updateCoverImage(String? path) {
    state = _copyWith(coverImagePath: path, clearCoverImage: path == null);
    _save();
  }

  /// Helper: creates a new UserProfileModel with optional field overrides.
  /// Riverpod detects new objects as state changes and triggers UI rebuild.
  UserProfileModel _copyWith({
    String? name,
    int? avatarIndex,
    String? avatarPath,
    bool clearAvatarPath = false,
    bool? notificationsEnabled,
    bool? plannerReminders,
    bool? habitReminders,
    bool? goalReminders,
    bool? focusAlerts,
    bool? soundsEnabled,
    String? globalSoundPath,
    bool clearGlobalSound = false,
    String? plannerSoundPath,
    bool clearPlannerSound = false,
    String? habitSoundPath,
    bool clearHabitSound = false,
    String? focusSoundPath,
    bool clearFocusSound = false,
    String? coverImagePath,
    bool clearCoverImage = false,
  }) {
    return UserProfileModel(
      name: name ?? state.name,
      avatarIndex: avatarIndex ?? state.avatarIndex,
      avatarPath: clearAvatarPath ? null : (avatarPath ?? state.avatarPath),
      notificationsEnabled: notificationsEnabled ?? state.notificationsEnabled,
      plannerReminders: plannerReminders ?? state.plannerReminders,
      habitReminders: habitReminders ?? state.habitReminders,
      goalReminders: goalReminders ?? state.goalReminders,
      focusAlerts: focusAlerts ?? state.focusAlerts,
      soundsEnabled: soundsEnabled ?? state.soundsEnabled,
      globalSoundPath: clearGlobalSound ? null : (globalSoundPath ?? state.globalSoundPath),
      plannerSoundPath: clearPlannerSound ? null : (plannerSoundPath ?? state.plannerSoundPath),
      habitSoundPath: clearHabitSound ? null : (habitSoundPath ?? state.habitSoundPath),
      focusSoundPath: clearFocusSound ? null : (focusSoundPath ?? state.focusSoundPath),
      coverImagePath: clearCoverImage ? null : (coverImagePath ?? state.coverImagePath),
    );
  }
}
