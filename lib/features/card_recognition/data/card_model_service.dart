import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img; // Nécessite package:image dans pubspec.yaml
import 'package:tflite_flutter/tflite_flutter.dart';

// Imports relatifs vers votre dossier common
import '../../../common/ai/interfaces/ai_repository.dart';
import '../../../common/ai/utils/yolo_post_processor.dart';
import '../../../common/ai/entities/detection_result.dart';

class CardModelService implements AIRepository {
  Interpreter? _interpreter;

  // --- CONFIGURATION ---
  static const String _modelPath = 'assets/models/best_float32.tflite';
  static const int _inputSize = 640;

  // Liste exacte issue de votre data.yaml
  static const List<String> _labels = [
    '10C', '10D', '10H', '10S', '2C', '2D', '2H', '2S',
    '3C', '3D', '3H', '3S', '4C', '4D', '4H', '4S',
    '5C', '5D', '5H', '5S', '6C', '6D', '6H', '6S',
    '7C', '7D', '7H', '7S', '8C', '8D', '8H', '8S',
    '9C', '9D', '9H', '9S', 'AC', 'AD', 'AH', 'AS',
    'JC', 'JD', 'JH', 'JS', 'KC', 'KD', 'KH', 'KS',
    'QC', 'QD', 'QH', 'QS'
  ];

  @override
  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      // options.addDelegate(GpuDelegateV2()); // Décommentez pour tester sur GPU

      _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
      print("✅ Modèle Cartes chargé avec succès.");
    } catch (e) {
      print("❌ Erreur chargement modèle Cartes: $e");
    }
  }

  @override
  Future<List<DetectionResult>> predict(dynamic input) async {
    if (_interpreter == null) throw Exception("Modèle non chargé");
    if (input is! File) throw Exception("CardModelService attend un fichier (File) en entrée");

    // 1. Lecture et décodage
    final bytes = await input.readAsBytes();
    final img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return [];

    // 2. Redimensionnement (Resize) vers 640x640
    final img.Image resizedImage = img.copyResize(
        originalImage,
        width: _inputSize,
        height: _inputSize,
        interpolation: img.Interpolation.linear
    );

    // 3. Conversion Tensor
    final inputTensor = _imageToFloat32List(resizedImage);

    // 4. Inférence
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final outputBuffer = List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);
    _interpreter!.run(inputTensor, outputBuffer);

    // 5. Post-Processing
    return YoloPostProcessor.process(outputBuffer, _labels);
  }

  @override
  void dispose() {
    _interpreter?.close();
  }

  List<dynamic> _imageToFloat32List(img.Image image) {
    final float32Bytes = Float32List(1 * _inputSize * _inputSize * 3);
    int pixelIndex = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        float32Bytes[pixelIndex++] = pixel.r / 255.0;
        float32Bytes[pixelIndex++] = pixel.g / 255.0;
        float32Bytes[pixelIndex++] = pixel.b / 255.0;
      }
    }
    return float32Bytes.reshape([1, _inputSize, _inputSize, 3]);
  }
}