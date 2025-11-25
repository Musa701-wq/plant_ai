// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden_plant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GardenPlantAdapter extends TypeAdapter<GardenPlant> {
  @override
  final int typeId = 1;

  @override
  GardenPlant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GardenPlant(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      imagePath: fields[3] as String,
      addedDate: fields[4] as DateTime,
      health: fields[5] as int,
      reminders: (fields[6] as List).cast<PlantReminder>(),
      scanId: fields[7] as String?,
      cachedPlantDetails: fields[8] as ScannedPlant?,
    );
  }

  @override
  void write(BinaryWriter writer, GardenPlant obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.addedDate)
      ..writeByte(5)
      ..write(obj.health)
      ..writeByte(6)
      ..write(obj.reminders)
      ..writeByte(7)
      ..write(obj.scanId)
      ..writeByte(8)
      ..write(obj.cachedPlantDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GardenPlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlantReminderAdapter extends TypeAdapter<PlantReminder> {
  @override
  final int typeId = 2;

  @override
  PlantReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantReminder(
      task: fields[0] as String,
      frequency: fields[1] as String,
      isActive: fields[2] as bool,
      id: fields[3] as String,
      repeatType: fields[4] as String,
      repeatInterval: fields[5] as int,
      time: fields[6] as DateTime,
      previousFertilizingLabel: fields[7] as String?,
      previousFertilizingDate: fields[8] as DateTime?,
      notificationIds: (fields[9] as List?)?.cast<int>(),
      plantId: fields[10] as String,
      plantName: fields[11] as String,
      isCompleted: fields[12] as bool,
      nextReminderDateTime: fields[13] as DateTime?,
      totalRounds: fields[14] as int,
      completedRounds: fields[15] as int,
      completedDates: (fields[16] as List?)?.cast<DateTime>(),
      lastCompletedDate: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PlantReminder obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.task)
      ..writeByte(1)
      ..write(obj.frequency)
      ..writeByte(2)
      ..write(obj.isActive)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.repeatType)
      ..writeByte(5)
      ..write(obj.repeatInterval)
      ..writeByte(6)
      ..write(obj.time)
      ..writeByte(7)
      ..write(obj.previousFertilizingLabel)
      ..writeByte(8)
      ..write(obj.previousFertilizingDate)
      ..writeByte(9)
      ..write(obj.notificationIds)
      ..writeByte(10)
      ..write(obj.plantId)
      ..writeByte(11)
      ..write(obj.plantName)
      ..writeByte(12)
      ..write(obj.isCompleted)
      ..writeByte(13)
      ..write(obj.nextReminderDateTime)
      ..writeByte(14)
      ..write(obj.totalRounds)
      ..writeByte(15)
      ..write(obj.completedRounds)
      ..writeByte(16)
      ..write(obj.completedDates)
      ..writeByte(17)
      ..write(obj.lastCompletedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
