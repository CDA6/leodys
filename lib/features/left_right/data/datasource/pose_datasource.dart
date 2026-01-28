import 'package:tflite_flutter/tflite_flutter.dart';

class PoseDataSource {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      // chargement du fichier .tflite depuis le dossier assets
      _interpreter = await Interpreter.fromAsset('assets/yolo11n-pose.tflite', options: options);
      // etape obligatoire : reserve la memoire pour les tenseurs
      _interpreter!.allocateTensors();
    } catch (e) {
      print("Erreur chargement modèle TFLite: $e");
    }
  }

  List<dynamic>? runInference(List<dynamic> inputTensor) {
    // securité : si le modele a pas chargé (fichier manquant?), on sort direct
    if (_interpreter == null) return null;

    try {
      // on recupere la structure de sortie attendue par le modele
      Tensor outputDetails = _interpreter!.getOutputTensor(0);
      // on prepare un tableau vide a la bonne taille pour stocker le resultat
      var outputBuffer = List.filled(outputDetails.numElements(), 0.0).reshape(outputDetails.shape);

      // lance le calcul d'inference
      _interpreter!.run(inputTensor, outputBuffer);
      return outputBuffer;
    } catch (e) {
      print("Erreur Inférence: $e");
      return null;
    }
  }

  void close() {
    // important de liberer la memoire quand on quitte l'ecran pour pas faire ramer le tel
    _interpreter?.close();
  }
}