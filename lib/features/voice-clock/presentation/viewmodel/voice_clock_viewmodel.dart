import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/repositories/clock_repository.dart';
import '../../domain/entities/clock_config.dart';
import '../../../notification/presentation/controllers/tts_controller.dart';

class VoiceClockViewModel extends ChangeNotifier {
  final IClockRepository _repository;
  final TtsController _ttsController;

  ClockType _selectedType = ClockType.digital;
  DateTime _currentTime = DateTime.now();

  VoiceClockViewModel(this._repository, this._ttsController) {
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

  Future<void> speakTime() async {
    final format = DateFormat('HH:mm');
    final timeStr = "Il est exactement ${format.format(_currentTime)}";
    await _ttsController.speak(timeStr);
  }
}