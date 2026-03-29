// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_block_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeBlockModelAdapter extends TypeAdapter<TimeBlockModel> {
  @override
  final int typeId = 3;

  @override
  TimeBlockModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeBlockModel(
      id: fields[0] as String,
      title: fields[1] as String,
      startTime: fields[2] as String,
      endTime: fields[3] as String,
      category: fields[4] as String,
      date: fields[5] as DateTime,
      isCompleted: fields[6] as bool,
      linkedTaskId: fields[7] as String?,
      note: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TimeBlockModel obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.linkedTaskId)
      ..writeByte(8)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeBlockModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
