import 'package:leodys/features/vehicle_recognition/domain/models/reader_config.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/plate_tts_repository.dart';

/// Gestion de la lecture vocale
class SpeakPlateUsecase {

  final PlateTtsRepository plateTtsRepository;
  SpeakPlateUsecase({required this.plateTtsRepository});

  /// Lnacer la lecture avec une configuration de lecture
  Future<void> play(String text, ReaderConfig config) async {


    if (text.trim().isEmpty) return;

    await plateTtsRepository.play(text, config);
  }

  /// Arrêter la lecture
  Future<void> stop() async{
    await plateTtsRepository.stop();
  }
}