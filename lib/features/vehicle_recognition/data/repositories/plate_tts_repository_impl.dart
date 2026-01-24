import 'package:leodys/features/vehicle_recognition/data/services/plate_tts_service.dart';
import 'package:leodys/features/vehicle_recognition/domain/models/plate_reader_config.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/plate_tts_repository.dart';


class PlateTtsRepositoryImpl implements PlateTtsRepository{

  final PlateTtsService plateTtsService;
  PlateTtsRepositoryImpl(this.plateTtsService);

  @override
  Future<void> play(String text, PlateReaderConfig config) async {

    await plateTtsService.speak
      (
        text: text,
        languageCode: config.languageCode,
        speechRate: config.speechRate,
        pitch: config.pitch
    );

  }

  @override
  Future<void> stop() async{
    await plateTtsService.stop();
  }


}