

import 'package:tflite_flutter/tflite_flutter.dart';

class PoseDataSource {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
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
      Tensor outputDetails = _interpreter!.getOutputTensor(0);
      var outputBuffer = List.filled(outputDetails.numElements(), 0.0).reshape(outputDetails.shape);

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