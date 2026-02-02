// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referent_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReferentEntityAdapter extends TypeAdapter<ReferentEntity> {
  @override
  final int typeId = 33;

  @override
  ReferentEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReferentEntity(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      role: fields[3] as String,
      category: fields[4] as String,
      userId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReferentEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferentEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
