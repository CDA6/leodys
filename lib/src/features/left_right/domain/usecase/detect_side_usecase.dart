import 'dart:typed_data';
import '../entity/body_part_entity.dart';
import '../repository/i_orientation_repository.dart';

class DetectSideUsecase {
  final IOrientationRepository repository;

  DetectSideUsecase(this.repository);

  // On remplace 'path' par les données de la frame
  Future<BodyPart> execute(Uint8List bytes, int h, int w, bool isFrontCamera) async {

    // 1. Appel au repository avec les bytes
    final part = await repository.analyzeFrame(bytes, h, w);

    // 2. Logique métier d'inversion (inchangée, c'est la force du UseCase)
    Side calculatedSide;
    if (isFrontCamera) {
      calculatedSide = part.x < 0.5 ? Side.right : Side.left;
    } else {
      calculatedSide = part.x < 0.5 ? Side.left : Side.right;
    }

    // 3. Retourne l'entité finale
    return part.copyWith(side: calculatedSide);
  }
}