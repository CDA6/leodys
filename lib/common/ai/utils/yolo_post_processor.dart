import 'dart:math';
import 'dart:ui';
import '../entities/detection_result.dart';

/// Utilitaire pour décoder la sortie brute (Tensor) de YOLOv8.
class YoloPostProcessor {
  // --- CONFIGURATION ---
  // Taille d'entrée du modèle (doit correspondre à l'entraînement)
  static const int _inputSize = 640;
  // Seuil de confiance minimal pour garder une détection
  static const double _confThreshold = 0.50;
  // Seuil de superposition pour le NMS
  static const double _iouThreshold = 0.15;

  /// Méthode principale de traitement.
  /// [output] : Le tensor brut sorti de l'interpréteur [1, Channels, Anchors]
  /// [labels] : La liste des noms de classes (Cartes ou Objets COCO)
  static List<DetectionResult> process(List<dynamic> output, List<String> labels) {
    List<DetectionResult> detections = [];

    // Structure standard YOLOv8 exportée : [Batch, Channels, Anchors]
    // output[0] accède au batch unique
    // output[0].length devrait être (4 coords + nb_classes)
    // output[0][0].length devrait être 8400 (nombre d'ancres)

    final int numAttributes = output[0].length;
    final int numAnchors = output[0][0].length;
    final int numClasses = labels.length;

    // 1. Extraction des candidats
    for (int i = 0; i < numAnchors; i++) {

      // A. Trouver la classe dominante pour cette ancre
      double maxClassScore = 0.0;
      int maxClassIndex = -1;

      // Les probabilités commencent à l'index 4 (après cx, cy, w, h)
      for (int c = 0; c < numClasses; c++) {
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
  static List<DetectionResult> _nonMaxSuppression(List<DetectionResult> boxes) {
    List<DetectionResult> finalBoxes = [];

    // On trie les boîtes par confiance décroissante
    boxes.sort((a, b) => b.confidence.compareTo(a.confidence));

    while (boxes.isNotEmpty) {
      DetectionResult current = boxes.first;
      finalBoxes.add(current);
      boxes.removeAt(0);

      boxes.removeWhere((other) {
        double iou = _calculateIoU(current.boundingBox, other.boundingBox);
        return iou > _iouThreshold;
      });
    }

    return finalBoxes;
  }

  /// Calcul de l'Intersection over Union (IoU)
  static double _calculateIoU(Rect boxA, Rect boxB) {
    final double intersectionLeft = max(boxA.left, boxB.left);
    final double intersectionTop = max(boxA.top, boxB.top);
    final double intersectionRight = min(boxA.right, boxB.right);
    final double intersectionBottom = min(boxA.bottom, boxB.bottom);

    if (intersectionRight < intersectionLeft || intersectionBottom < intersectionTop) {
      return 0.0;
    }

    final double intersectionArea = (intersectionRight - intersectionLeft) * (intersectionBottom - intersectionTop);
    final double boxAArea = boxA.width * boxA.height;
    final double boxBArea = boxB.width * boxB.height;
    final double unionArea = boxAArea + boxBArea - intersectionArea;

    if (unionArea == 0) return 0.0;

    return intersectionArea / unionArea;
  }
}