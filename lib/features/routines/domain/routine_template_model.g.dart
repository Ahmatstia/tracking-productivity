// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_template_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineBlockModelAdapter extends TypeAdapter<RoutineBlockModel> {
  @override
  final int typeId = 8;

  @override
  RoutineBlockModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineBlockModel(
      title: fields[0] as String,
      startTime: fields[1] as String,
      endTime: fields[2] as String,
      category: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineBlockModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineBlockModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoutineTemplateModelAdapter extends TypeAdapter<RoutineTemplateModel> {
  @override
  final int typeId = 7;

  @override
  RoutineTemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineTemplateModel(
      id: fields[0] as String,
      name: fields[1] as String,
      blocks: (fields[2] as List).cast<RoutineBlockModel>(),
      assignedDays: (fields[3] as List).cast<int>(),
      colorCode: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineTemplateModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.blocks)
      ..writeByte(3)
      ..write(obj.assignedDays)
      ..writeByte(4)
      ..write(obj.colorCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineTemplateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
