import 'package:tflite_flutter/tflite_flutter.dart';

class PoseDataSource {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      // on configure l'interpreteur avec 4 threads
      final options = InterpreterOptions()..threads = 4;

      // chargement du modele depuis les assets
      _interpreter = await Interpreter.fromAsset('assets/yolo11n-pose.tflite', options: options);

      // allocation des tenseurs en memoire
      _interpreter!.allocateTensors();

    } catch (e) {
      print("Erreur TFLite: $e");
    }
  }

  List<dynamic>? runInference(List<dynamic> inputTensor) {
    // si le modele n'est pas chargé
    if (_interpreter == null) return null;

    //recupere les infos sur la sortie attendue
    Tensor outputDetails = _interpreter!.getOutputTensor(0);

    // prepare le buffer de sortie avec la bonne forme
    var outputBuffer = List.filled(outputDetails.numElements(), 0.0).reshape(outputDetails.shape);

    // inference : input -> modele -> output
    _interpreter!.run(inputTensor, outputBuffer);

    return outputBuffer;
  }

  void close() => _interpreter?.close();
}