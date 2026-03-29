// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusSessionModelAdapter extends TypeAdapter<FocusSessionModel> {
  @override
  final int typeId = 5;

  @override
  FocusSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSessionModel(
      id: fields[0] as String,
      taskId: fields[1] as String?,
      date: fields[2] as DateTime,
      durationSeconds: fields[3] as int,
      isFocusMode: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSessionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.isFocusMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
