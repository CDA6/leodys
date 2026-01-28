import 'package:flutter/foundation.dart';
import '../../domain/models/plate_scan.dart';
import '../../domain/models/plate_reader_config.dart';
import '../../domain/usecases/speak_plate_usecase.dart';

class PlateTtsController extends ChangeNotifier {

  final SpeakPlateUsecase speakPlateUsecase;
  final PlateReaderConfig readerConfig;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  PlateTtsController({
    required this.speakPlateUsecase,
    required this.readerConfig,
  });

  Future<void> play(PlateScan scan) async {
    _isPlaying = true;
    notifyListeners();

    await speakPlateUsecase.play(
      scan.vehicleLabel,
      readerConfig,
    );

    _isPlaying = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await speakPlateUsecase.stop();
    _isPlaying = false;
    notifyListeners();
  }
}
