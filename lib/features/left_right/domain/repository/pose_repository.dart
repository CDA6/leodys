
import '../entity/body_part_entity.dart';

abstract class PoseRepository {
  Future<List<BodyPoint>> detectPose(dynamic cameraImage, {required int sensorOrientation});
}