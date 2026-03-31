import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 10)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int avatarIndex; // 0-based index for preset avatars

  @HiveField(2)
  String? avatarPath; // Future use for gallery upload

  @HiveField(3)
  bool notificationsEnabled;

  @HiveField(4)
  bool plannerReminders;

  @HiveField(5)
  bool habitReminders;

  @HiveField(6)
  bool goalReminders;

  @HiveField(7)
  bool focusAlerts;

  @HiveField(8)
  bool soundsEnabled;

  @HiveField(9)
  String? globalSoundPath;

  @HiveField(10)
  String? plannerSoundPath;

  @HiveField(11)
  String? habitSoundPath;

  @HiveField(12)
  String? focusSoundPath;

  UserProfileModel({
    this.name = 'Sobat Produktif',
    this.avatarIndex = 0,
    this.avatarPath,
    this.notificationsEnabled = true,
    this.plannerReminders = true,
    this.habitReminders = true,
    this.goalReminders = true,
    this.focusAlerts = true,
    this.soundsEnabled = true,
    this.globalSoundPath,
    this.plannerSoundPath,
    this.habitSoundPath,
    this.focusSoundPath,
  });
}
