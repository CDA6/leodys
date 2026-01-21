import 'dart:math' as math;

import '../entity/body_part_entity.dart';
import '../repository/pose_repository.dart';

class DetectPoseUseCase {
  final PoseRepository repository;

  DetectPoseUseCase(this.repository);

  Future<List<BodyPoint>> call(dynamic image, {required int sensorOrientation}) async {
    // 1. Récupération des points via le repository
    List<BodyPoint> points = await repository.detectPose(image, sensorOrientation: sensorOrientation);

    // 2. Logique métier : Nettoyage des poignets superposés
    return _filterImpossibleWrists(points);
  }

  List<BodyPoint> _filterImpossibleWrists(List<BodyPoint> points) {
    try {
      // On cherche si on a les deux poignets
      var leftWrist = points.firstWhere((p) => p.label == "Poignet G");
      var rightWrist = points.firstWhere((p) => p.label == "Poignet D");

      // Calcul de la distance euclidienne
      double distance = math.sqrt(math.pow(leftWrist.x - rightWrist.x, 2) +
          math.pow(leftWrist.y - rightWrist.y, 2));

      // Si trop proches (< 5% de l'écran), c'est suspect
      if (distance < 0.05) {
        // On supprime celui qui a la confiance la plus basse
        if (leftWrist.confidence < rightWrist.confidence) {
          points.remove(leftWrist);
        } else {
          points.remove(rightWrist);
        }
      }
    } catch (e) {
      // Si un poignet manque, pas de filtrage à faire
    }
    return points;
  }
}