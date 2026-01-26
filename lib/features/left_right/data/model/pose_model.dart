import '../../domain/entity/body_part_entity.dart';


class PoseModel {
  static List<BodyPoint> fromTfliteOutput(List<dynamic> output) {
    var data = output[0];
    int dim1 = data.length;
    int dim2 = data[0].length;
    double maxScore = 0.0;
    List<dynamic>? bestBox;

    // Gestion de la transposition (YOLO peut sortir [Batch, 56, 8400] ou [Batch, 8400, 56])
    if (dim1 > dim2) {
      for (int i = 0; i < dim1; i++) {
        if (data[i][4] > maxScore) { maxScore = data[i][4]; bestBox = data[i]; }
      }
    } else {
      int bestIdx = -1;
      for (int i = 0; i < dim2; i++) {
        if (data[4][i] > maxScore) { maxScore = data[4][i]; bestIdx = i; }
      }
      if (bestIdx != -1) {
        bestBox = [];
        for(int row=0; row<dim1; row++) bestBox.add(data[row][bestIdx]);
      }
    }

    List<BodyPoint> points = [];
    final names = ["Nez", "Oeil G", "Oeil D", "Oreille G", "Oreille D", "Epaule G", "Epaule D",
      "Coude G", "Coude D", "Poignet G", "Poignet D", "Hanche G", "Hanche D",
      "Genou G", "Genou D", "Cheville G", "Cheville D"];

    // Seuil de confiance global (0.20)
    if (maxScore > 0.40 && bestBox != null) {
      for (int k = 0; k < 17; k++) {
        int idx = 5 + (k * 3);
        double x = bestBox[idx];
        double y = bestBox[idx+1];
        double conf = bestBox[idx+2];

        // Seuil par point (0.15)
        if (conf > 0.40) {
          points.add(BodyPoint(
              x: x,
              y: y,
              label: names[k],
              // Mapping des indices pairs/impairs vers Gauche/Droite
              side: k % 2 == 0 ? BodySide.right : BodySide.left,
              confidence: conf
          ));
        }
      }
    }
    return points;
  }
}