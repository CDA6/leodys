import 'dart:math';
import 'dart:ui'; // Pour Rect
import '../services/ai_handler.dart'; // Import de votre entité DetectionResult

/// Utilitaire pour décoder la sortie brute (Tensor) de YOLOv8.
class YoloPostProcessor {
  // --- CONFIGURATION ---
  // Taille d'entrée du modèle (doit correspondre à l'entraînement)
  static const int _inputSize = 640;
  // Seuil de confiance minimal pour garder une détection (45%)
  static const double _confThreshold = 0.45;
  // Seuil de superposition pour le NMS (45%)
  static const double _iouThreshold = 0.45;

  /// Méthode principale de traitement.
  /// [output] : Le tensor brut sorti de l'interpréteur [1, Channels, Anchors]
  /// [labels] : La liste des noms de classes (Cartes ou Objets COCO)
  static List<DetectionResult> process(List<dynamic> output, List<String> labels) {
    List<DetectionResult> detections = [];

    // YOLOv8 Structure de sortie standard : [Batch, Channels, Anchors]
    // Batch = 1
    // Channels = 4 (coords x,y,w,h) + nombre_de_classes
    // Anchors = 8400 (pour une image 640x640)

    // Vérification de sécurité dimensionnelle
    // output[0] accède au batch unique
    final int numAttributes = output[0].length; // Devrait être (4 + nb_classes)
    final int numAnchors = output[0][0].length; // Devrait être 8400

    final int numClasses = labels.length;

    // 1. Extraction des candidats
    // On boucle sur chaque ancre (colonne)
    for (int i = 0; i < numAnchors; i++) {

      // A. Trouver la classe dominante pour cette ancre
      double maxClassScore = 0.0;
      int maxClassIndex = -1;

      // Les probabilités commencent à l'index 4 (après cx, cy, w, h)
      // Note : output[0][c][i] -> Batch 0, Attribut c, Ancre i
      for (int c = 0; c < numClasses; c++) {
        // +4 car les 4 premiers attributs sont les coordonnées
        double score = output[0][4 + c][i];

        if (score > maxClassScore) {
          maxClassScore = score;
          maxClassIndex = c;
        }
      }

      // B. Filtre de confiance
      if (maxClassScore > _confThreshold) {
        // C. Extraction des coordonnées géométriques
        // 0: center_x, 1: center_y, 2: width, 3: height
        final double cx = output[0][0][i];
        final double cy = output[0][1][i];
        final double w = output[0][2][i];
        final double h = output[0][3][i];

        // Conversion (Centre, Taille) -> (Haut, Gauche, Bas, Droite)
        final double left = cx - (w / 2);
        final double top = cy - (h / 2);
        final double right = cx + (w / 2);
        final double bottom = cy + (h / 2);

        // Création du rectangle (coordonnées dans l'espace 640x640)
        final rect = Rect.fromLTRB(
            max(0, left),
            max(0, top),
            min(_inputSize.toDouble(), right),
            min(_inputSize.toDouble(), bottom)
        );

        detections.add(DetectionResult(
          label: labels[maxClassIndex],
          confidence: maxClassScore,
          boundingBox: rect,
        ));
      }
    }

    // 2. Suppression des doublons (Non-Maximum Suppression)
    return _nonMaxSuppression(detections);
  }

  /// Algorithme NMS (Non-Maximum Suppression)
  /// Élimine les boîtes qui se chevauchent trop pour ne garder que la meilleure.
  static List<DetectionResult> _nonMaxSuppression(List<DetectionResult> boxes) {
    List<DetectionResult> finalBoxes = [];

    // On trie les boîtes par confiance décroissante (la plus sûre en premier)
    boxes.sort((a, b) => b.confidence.compareTo(a.confidence));

    while (boxes.isNotEmpty) {
      // On prend la meilleure boîte restante
      DetectionResult current = boxes.first;
      finalBoxes.add(current);
      boxes.removeAt(0);

      // On compare cette boîte avec toutes les autres restantes
      // Si une autre boîte se superpose trop (IoU > seuil), on la supprime
      boxes.removeWhere((other) {
        double iou = _calculateIoU(current.boundingBox, other.boundingBox);
        return iou > _iouThreshold;
      });
    }

    return finalBoxes;
  }

  /// Calcul de l'Intersection over Union (IoU) entre deux rectangles
  static double _calculateIoU(Rect boxA, Rect boxB) {
    final double intersectionLeft = max(boxA.left, boxB.left);
    final double intersectionTop = max(boxA.top, boxB.top);
    final double intersectionRight = min(boxA.right, boxB.right);
    final double intersectionBottom = min(boxA.bottom, boxB.bottom);

    if (intersectionRight < intersectionLeft || intersectionBottom < intersectionTop) {
      return 0.0; // Pas d'intersection
    }

    final double intersectionArea = (intersectionRight - intersectionLeft) * (intersectionBottom - intersectionTop);

    final double boxAArea = boxA.width * boxA.height;
    final double boxBArea = boxB.width * boxB.height;

    // Union = Surface A + Surface B - Surface Intersection
    final double unionArea = boxAArea + boxBArea - intersectionArea;

    if (unionArea == 0) return 0.0;

    return intersectionArea / unionArea;
  }
}