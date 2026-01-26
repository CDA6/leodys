import '../../domain/entity/body_part_entity.dart';

class PoseModel {
  static List<BodyPoint> fromTfliteOutput(List<dynamic> output) {
    var data = output[0];
    // on recup les dims pour savoir dans quel sens lire le tableau
    int dim1 = data.length;
    int dim2 = data[0].length;
    double maxScore = 0.0;
    List<dynamic>? bestBox;

    // gestion transposition : yolo est capricieux
    // des fois il sort [batch, 56, 8400] des fois l'inverse, faut gerer les deux cas
    if (dim1 > dim2) {
      // cas facile ligne par ligne
      for (int i = 0; i < dim1; i++) {
        if (data[i][4] > maxScore) { maxScore = data[i][4]; bestBox = data[i]; }
      }
    } else {
      // cas relou colonne par colonne : on doit transposer
      int bestIdx = -1;
      for (int i = 0; i < dim2; i++) {
        if (data[4][i] > maxScore) { maxScore = data[4][i]; bestIdx = i; }
      }
      if (bestIdx != -1) {
        bestBox = [];
        // on reconstruit la liste de donnees pour la meilleure detection
        for(int row=0; row<dim1; row++) bestBox.add(data[row][bestIdx]);
      }
    }

    List<BodyPoint> points = [];
    // noms officiels du format coco keypoints
    final names = ["Nez", "Oeil G", "Oeil D", "Oreille G", "Oreille D", "Epaule G", "Epaule D",
      "Coude G", "Coude D", "Poignet G", "Poignet D", "Hanche G", "Hanche D",
      "Genou G", "Genou D", "Cheville G", "Cheville D"];

    // seuil de confiance global (40%) : si c'est flou on prend pas
    if (maxScore > 0.40 && bestBox != null) {
      // boucle sur les 17 points du squelette
      for (int k = 0; k < 17; k++) {
        // calcul index : 5 premiers float = la boite, ensuite c'est par paquet de 3 (x,y,conf)
        int idx = 5 + (k * 3);
        double x = bestBox[idx];
        double y = bestBox[idx+1];
        double conf = bestBox[idx+2];

        // seuil par point : on garde que ceux ou l'ia est sure d'elle
        if (conf > 0.40) {
          points.add(BodyPoint(
              x: x,
              y: y,
              label: names[k],
              // astuce pair/impair pour deviner le coté (nez sera a droite mais osef c au milieu)
              side: k % 2 == 0 ? BodySide.right : BodySide.left,
              confidence: conf
          ));
        }
      }
    }
    return points;
  }
}