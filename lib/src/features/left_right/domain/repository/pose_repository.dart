
import '../entity/body_part_entity.dart';

abstract class PoseRepository {
  // Le contrat exige l'image brute ET l'orientation réelle du capteur
  Future<List<BodyPoint>> detectPose(dynamic cameraImage, {required int sensorOrientation});
}