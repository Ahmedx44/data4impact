// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentUserHiveAdapter extends TypeAdapter<CurrentUserHive> {
  @override
  final int typeId = 2;

  @override
  CurrentUserHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentUserHive(
      id: fields[0] as String,
      firstName: fields[1] as String,
      middleName: fields[2] as String?,
      lastName: fields[3] as String,
      role: fields[4] as String,
      phone: fields[5] as String?,
      email: fields[6] as String,
      emailVerified: fields[7] as bool,
      imageUrl: fields[8] as String?,
      active: fields[9] as bool,
      systemOwner: fields[10] as bool,
      createdAt: fields[11] as String,
      updatedAt: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentUserHive obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.middleName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.emailVerified)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.active)
      ..writeByte(10)
      ..write(obj.systemOwner)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentUserHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
