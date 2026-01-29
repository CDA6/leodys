import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/repositories/clock_repository.dart';
import '../../domain/entities/clock_config.dart';

class VoiceClockViewModel extends ChangeNotifier {
  final IClockRepository _repository;

  ClockType _selectedType = ClockType.digital;
  DateTime _currentTime = DateTime.now();

  StreamSubscription<DateTime>? _timeSubscription;


  VoiceClockViewModel(this._repository) {
    _timeSubscription = _repository.getCurrentTime().listen((time) {
      _currentTime = time;
      notifyListeners();
    });
  }

  DateTime get currentTime => _currentTime;
  ClockType get selectedType => _selectedType;

  void setClockType(ClockType type) {
    _selectedType = type;
    notifyListeners();
  }

  @override
  void dispose() {
    _timeSubscription?.cancel();
    super.dispose();
  }

}