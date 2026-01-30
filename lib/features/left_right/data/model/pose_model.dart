import '../../domain/entity/body_part_entity.dart';

class PoseModel {
  static List<BodyPoint> fromTfliteOutput(List<dynamic> output) {
    // la sortie de yolo c'est [1, 56, 8400]
    // data[0] contient 56 lignes (x, y, w, h, score, puis les keypoints)
    // chaque ligne a 8400 valeurs = une par boite potentielle
    var data = output[0];

    // yolo genere 8400 propositions de detection
    int totalColonnes = data[0].length;

    double maxScore = 0.0;
    int bestCol = -1;

    // 1. on cherche la colonne avec le meilleur score (= le bonhomme le mieux detecté)
    for (int i = 0; i < totalColonnes; i++) {
      // le score de la boite est a la ligne 4
      double score = data[4][i];
      if (score > maxScore) {
        maxScore = score;
        bestCol = i;
      }
    }

    List<BodyPoint> points = [];

    // 2. si on a un bon score (> 40%), on extrait les keypoints
    if (maxScore > 0.40 && bestCol != -1) {
      // les 17 keypoints du format COCO
      final names = [
        "Nez", "Oeil G", "Oeil D", "Oreille G", "Oreille D",
        "Epaule G", "Epaule D", "Coude G", "Coude D",
        "Poignet G", "Poignet D", "Hanche G", "Hanche D",
        "Genou G", "Genou D", "Cheville G", "Cheville D"
      ];

      for (int k = 0; k < 17; k++) {
        // les keypoints commencent a la ligne 5
        // chaque point occupe 3 lignes : x, y, confidence
        int rowIdx = 5 + (k * 3);

        // on lit les valeurs dans la colonne du meilleur bonhomme
        double x = data[rowIdx][bestCol];
        double y = data[rowIdx + 1][bestCol];
        double conf = data[rowIdx + 2][bestCol];

        // on garde seulement les points avec une bonne confiance
        if (conf > 0.40) {
          points.add(BodyPoint(
              x: x,
              y: y,
              label: names[k],
              //dans les points COCO impair gauche , pair droite
              side: k % 2 == 0 ? BodySide.right : BodySide.left,
              confidence: conf
          ));
        }
      }
    }
    return points;
  }
}