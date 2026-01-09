import '../entity/body_part.dart';
// Ici on importe l'interface du repository, pas l'implémentation technique
import '../repository/i_orientation_repository.dart';

class DetectSideUsecase {
  final IOrientationRepository repository;

  DetectSideUsecase(this.repository);

// La méthode qui sera appelée par le ViewModel
  Future<BodyPart> execute(String imagePath) async {
    // On pourrait ajouter ici une logique métier supplémentaire
    // Par exemple : si la confiance est < 70%, on renvoie "Inconnu"
    return await repository.analyzeImage(imagePath);
  }
}