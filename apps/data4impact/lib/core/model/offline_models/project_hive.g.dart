// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectHiveAdapter extends TypeAdapter<ProjectHive> {
  @override
  final int typeId = 0;

  @override
  ProjectHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectHive(
      id: fields[0] as String,
      slug: fields[1] as String,
      title: fields[2] as String,
      organization: fields[3] as String,
      userId: fields[4] as String,
      status: fields[5] as String,
      studiesCount: fields[6] as int,
      contributorsCount: fields[7] as int,
      description: fields[8] as String,
      visibility: fields[9] as String,
      priority: fields[10] as String?,
      country: fields[11] as String?,
      sector: fields[12] as String?,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectHive obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.slug)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.organization)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.studiesCount)
      ..writeByte(7)
      ..write(obj.contributorsCount)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.visibility)
      ..writeByte(10)
      ..write(obj.priority)
      ..writeByte(11)
      ..write(obj.country)
      ..writeByte(12)
      ..write(obj.sector)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
