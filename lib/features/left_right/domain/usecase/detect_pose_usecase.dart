import 'dart:math' as math;

import '../entity/body_part_entity.dart';
import '../repository/pose_repository.dart';

class DetectPoseUseCase {
  final PoseRepository repository;

  DetectPoseUseCase(this.repository);

  Future<List<BodyPoint>> call(dynamic image, {required int sensorOrientation}) async {
    // recupere les points bruts du repo
    List<BodyPoint> points = await repository.detectPose(image, sensorOrientation: sensorOrientation);

    // petit filtre maison pour eviter les bugs quand les mains se croisent
    return _filterImpossibleWrists(points);
  }

  List<BodyPoint> _filterImpossibleWrists(List<BodyPoint> points) {
    try {
      // on cherche les 2 poignets dans la liste
      // note : firstWhere plante s'il trouve pas, le try/catch gere ca
      var leftWrist = points.firstWhere((p) => p.label == "Poignet G");
      var rightWrist = points.firstWhere((p) => p.label == "Poignet D");

      // calcul distance math entre les 2 (pythagore classique)
      double distance = math.sqrt(math.pow(leftWrist.x - rightWrist.x, 2) +
          math.pow(leftWrist.y - rightWrist.y, 2));

      // si trop proches (< 5% de l'ecran), c'est souvent que l'ia confond les deux mains
      if (distance < 0.05) {
        // on vire celui qui a la confiance la plus basse pour garder le "vrai"
        if (leftWrist.confidence < rightWrist.confidence) {
          points.remove(leftWrist);
        } else {
          points.remove(rightWrist);
        }
      }
    } catch (e) {
      // si un poignet manque ou les deux, pas de conflit possible, on touche a rien
    }
    return points;
  }
}