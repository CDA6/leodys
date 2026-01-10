import 'dart:typed_data';

abstract class IYoloLocalDataSource {
  // On passe les octets de l'image, la hauteur et la largeur
  Future<List<dynamic>> predictFrame(Uint8List bytes, int height, int width);
}

class YoloLocalDataSourceImpl implements IYoloLocalDataSource {

  @override
  Future<List<dynamic>> predictFrame(Uint8List bytes, int height, int width) async {
    // 1. Ici, on appelle la lib technique (ex: flutter_vision ou tflite)
    // 2. Elle traite les bytes avec le modèle chargé en mémoire

    // Logique technique Yolo (Inférence sur les bytes)
    return []; // Retourne les détections : [{ "x": 0.4, "y": 0.5, "label": "hand", ... }]
  }
}