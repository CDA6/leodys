import 'dart:typed_data';

import '../entity/body_part_entity.dart';

abstract class IOrientationRepository {
  // On définit juste la signature de la méthode
  Future<BodyPart> analyzeFrame(Uint8List bytes, int height, int width);
}