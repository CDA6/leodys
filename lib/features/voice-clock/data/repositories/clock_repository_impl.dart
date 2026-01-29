import 'dart:async';
import '../../domain/repositories/clock_repository.dart';

class ClockRepositoryImpl implements IClockRepository {
  @override
  Stream<DateTime> getCurrentTime() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }
}