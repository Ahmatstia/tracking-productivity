// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_review_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyReviewModelAdapter extends TypeAdapter<DailyReviewModel> {
  @override
  final int typeId = 9;

  @override
  DailyReviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyReviewModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      moodRating: fields[2] as int,
      whatWentWell: fields[3] as String,
      whatToImprove: fields[4] as String,
      tasksCompleted: fields[5] as int,
      totalTasks: fields[6] as int,
      focusMinutes: fields[7] as int,
      productivityScore: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyReviewModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.moodRating)
      ..writeByte(3)
      ..write(obj.whatWentWell)
      ..writeByte(4)
      ..write(obj.whatToImprove)
      ..writeByte(5)
      ..write(obj.tasksCompleted)
      ..writeByte(6)
      ..write(obj.totalTasks)
      ..writeByte(7)
      ..write(obj.focusMinutes)
      ..writeByte(8)
      ..write(obj.productivityScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyReviewModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
