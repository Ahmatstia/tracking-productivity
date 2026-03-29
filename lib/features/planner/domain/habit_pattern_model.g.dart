// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_pattern_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitPatternModelAdapter extends TypeAdapter<HabitPatternModel> {
  @override
  final int typeId = 4;

  @override
  HabitPatternModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitPatternModel(
      id: fields[0] as String,
      title: fields[1] as String,
      startTime: fields[2] as String,
      endTime: fields[3] as String,
      category: fields[4] as String,
      daysOfWeek: (fields[5] as List).cast<int>(),
      occurrenceCount: fields[6] as int,
      isActive: fields[7] as bool,
      lastAppliedDate: fields[8] as DateTime?,
      note: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitPatternModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.daysOfWeek)
      ..writeByte(6)
      ..write(obj.occurrenceCount)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.lastAppliedDate)
      ..writeByte(9)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitPatternModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
