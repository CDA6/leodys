// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentTransactionAdapter extends TypeAdapter<PaymentTransaction> {
  @override
  final int typeId = 0;

  @override
  PaymentTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentTransaction(
      id: fields[0] as String,
      amount: fields[1] as double,
      paymentMethod: fields[2] as String,
      date: fields[3] as DateTime,
      isSuccess: fields[4] as bool,
      details: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentTransaction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.paymentMethod)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.isSuccess)
      ..writeByte(5)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
