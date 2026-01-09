import '../entity/body_part.dart';

abstract class IOrientationRepository {
  // On définit juste la signature de la méthode
  Future<BodyPart> analyzeImage(String path);
}