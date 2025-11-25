// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_plant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScannedPlantAdapter extends TypeAdapter<ScannedPlant> {
  @override
  final int typeId = 10;

  @override
  ScannedPlant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScannedPlant(
      id: fields[0] as String,
      name: fields[1] as String?,
      scientificName: fields[2] as String?,
      confidence: fields[3] as double?,
      about: fields[4] as String?,
      details: fields[5] as PlantDetailsHive?,
      commonProblems: fields[6] as String?,
      faqs: (fields[7] as List?)?.cast<FAQItemHive>(),
      funFacts: (fields[8] as List?)?.cast<String>(),
      imagePath: fields[9] as String?,
      scannedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ScannedPlant obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.scientificName)
      ..writeByte(3)
      ..write(obj.confidence)
      ..writeByte(4)
      ..write(obj.about)
      ..writeByte(5)
      ..write(obj.details)
      ..writeByte(6)
      ..write(obj.commonProblems)
      ..writeByte(7)
      ..write(obj.faqs)
      ..writeByte(8)
      ..write(obj.funFacts)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(10)
      ..write(obj.scannedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedPlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlantDetailsHiveAdapter extends TypeAdapter<PlantDetailsHive> {
  @override
  final int typeId = 11;

  @override
  PlantDetailsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantDetailsHive(
      temperatureRange: fields[0] as String?,
      sunlight: fields[1] as String?,
      watering: fields[2] as String?,
      repotting: fields[3] as String?,
      fertilizing: fields[4] as String?,
      pests: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlantDetailsHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.temperatureRange)
      ..writeByte(1)
      ..write(obj.sunlight)
      ..writeByte(2)
      ..write(obj.watering)
      ..writeByte(3)
      ..write(obj.repotting)
      ..writeByte(4)
      ..write(obj.fertilizing)
      ..writeByte(5)
      ..write(obj.pests);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantDetailsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FAQItemHiveAdapter extends TypeAdapter<FAQItemHive> {
  @override
  final int typeId = 12;

  @override
  FAQItemHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FAQItemHive(
      question: fields[0] as String?,
      answer: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FAQItemHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.answer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FAQItemHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
