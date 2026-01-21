import 'package:tflite_flutter/tflite_flutter.dart';

class PoseDataSource {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      // Utilisation de 4 threads pour la performance
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset('assets/yolo11n-pose.tflite', options: options);
      _interpreter!.allocateTensors();
    } catch (e) {
      print("Erreur chargement modèle TFLite: $e");
    }
  }

  List<dynamic>? runInference(List<dynamic> inputTensor) {
    if (_interpreter == null) return null;

    try {
      // Préparation du buffer de sortie selon la forme du tenseur du modèle
      Tensor outputDetails = _interpreter!.getOutputTensor(0);
      var outputBuffer = List.filled(outputDetails.numElements(), 0.0).reshape(outputDetails.shape);

      // Exécution
      _interpreter!.run(inputTensor, outputBuffer);
      return outputBuffer;
    } catch (e) {
      print("Erreur Inférence: $e");
      return null;
    }
  }

  void close() {
    _interpreter?.close();
  }
}