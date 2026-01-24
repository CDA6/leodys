import 'package:leodys/features/vehicle_recognition/domain/models/plate_reader_config.dart';

/// Classe abstraite ttsRepository qui représente une interface.
/// Elle définit les contrats que les classes de la couche data devront implémenter
abstract class PlateTtsRepository {

  /// Lance la lecture vocale
  Future<void> play(String text, PlateReaderConfig config);

  /// Stop completement la lecture vocale
  Future<void> stop();
}