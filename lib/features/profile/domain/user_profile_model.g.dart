// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 10;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      name: fields[0] as String,
      avatarIndex: fields[1] as int,
      avatarPath: fields[2] as String?,
      notificationsEnabled: fields[3] as bool,
      plannerReminders: fields[4] as bool,
      habitReminders: fields[5] as bool,
      goalReminders: fields[6] as bool,
      focusAlerts: fields[7] as bool,
      soundsEnabled: fields[8] as bool,
      globalSoundPath: fields[9] as String?,
      plannerSoundPath: fields[10] as String?,
      habitSoundPath: fields[11] as String?,
      focusSoundPath: fields[12] as String?,
      coverImagePath: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.avatarIndex)
      ..writeByte(2)
      ..write(obj.avatarPath)
      ..writeByte(3)
      ..write(obj.notificationsEnabled)
      ..writeByte(4)
      ..write(obj.plannerReminders)
      ..writeByte(5)
      ..write(obj.habitReminders)
      ..writeByte(6)
      ..write(obj.goalReminders)
      ..writeByte(7)
      ..write(obj.focusAlerts)
      ..writeByte(8)
      ..write(obj.soundsEnabled)
      ..writeByte(9)
      ..write(obj.globalSoundPath)
      ..writeByte(10)
      ..write(obj.plannerSoundPath)
      ..writeByte(11)
      ..write(obj.habitSoundPath)
      ..writeByte(12)
      ..write(obj.focusSoundPath)
      ..writeByte(13)
      ..write(obj.coverImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
