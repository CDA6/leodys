import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../common/ai/entities/detection_result.dart';
import '../../../../common/ai/interfaces/ai_repository.dart';
import '../../../../common/ai/utils/yolo_post_processor.dart';

class CardModelDatasource implements AIRepository {
  Interpreter? _interpreter;

  // --- CONFIGURATION ---
  static const String _modelPath = 'assets/models/best_float32.tflite';
  static const int _inputSize = 640;

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
      _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
      print("✅ Modèle Cartes chargé (Mode Letterbox activé).");
    } catch (e) {
      print("❌ Erreur chargement modèle Cartes: $e");
    }
  }

  @override
  Future<List<DetectionResult>> predict(dynamic input) async {
    if (_interpreter == null) throw Exception("Modèle non chargé");
    if (input is! File) throw Exception("CardModelService attend un fichier (File)");

    // 1. Lecture
    final bytes = await input.readAsBytes();
    final img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return [];

    // 2. LETTERBOXING
    final img.Image inputImage = img.Image(width: _inputSize, height: _inputSize);
    img.fill(inputImage, color: img.ColorRgb8(114, 114, 114));

    // Calcul du ratio pour garder les proportions
    double ratio = _inputSize / (originalImage.width > originalImage.height ? originalImage.width : originalImage.height);
    int newWidth = (originalImage.width * ratio).round();
    int newHeight = (originalImage.height * ratio).round();

    // redimensionne l'original proprement
    final img.Image scaledImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear
    );

    // On colle l'image redimensionnée au centre du carré gris
    int dstX = (_inputSize - newWidth) ~/ 2;
    int dstY = (_inputSize - newHeight) ~/ 2;
    img.compositeImage(inputImage, scaledImage, dstX: dstX, dstY: dstY);

    // 3. Conversion en Tensor
    final inputTensor = _imageToFloat32List(inputImage);

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