import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../vocal_notes/data/services/speech_service.dart';
import '../../domain/repositories/clock_repository.dart';
import '../../domain/entities/clock_config.dart';
import '../../../vocal_notes/data/services/speech_service.dart';
import '../../../vocal_notes/injection_container.dart';

class VoiceClockViewModel extends ChangeNotifier {
  final IClockRepository _repository;

  ClockType _selectedType = ClockType.digital;
  DateTime _currentTime = DateTime.now();


  VoiceClockViewModel(this._repository) {
    _repository.getCurrentTime().listen((time) {
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

}