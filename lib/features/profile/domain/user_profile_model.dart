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

  UserProfileModel({
    this.name = 'Sobat Produktif',
    this.avatarIndex = 0,
    this.avatarPath,
    this.notificationsEnabled = true,
  });
}
