import 'dart:typed_data';
import 'package:camera/camera.dart'; // Nécessite package:camera
import 'package:tflite_flutter/tflite_flutter.dart';

// Imports relatifs vers votre dossier common
import '../../../common/ai/interfaces/ai_repository.dart';
import '../../../common/ai/utils/yolo_post_processor.dart';
import '../../../common/ai/entities/detection_result.dart';

class DomesticModelService implements AIRepository {
  Interpreter? _interpreter;

  // --- CONFIGURATION ---
  static const String _modelPath = 'assets/models/yolo26n_float32.tflite'; // Votre modèle 'yolo26'
  static const int _inputSize = 640;

  // Liste des 80 classes COCO (issue de coco.yaml)
  static const List<String> _labels = [
    "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat", "traffic light",
    "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat", "dog", "horse", "sheep", "cow",
    "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella", "handbag", "tie", "suitcase", "frisbee",
    "skis", "snowboard", "sports ball", "kite", "baseball bat", "baseball glove", "skateboard", "surfboard",
    "tennis racket", "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple",
    "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair", "couch",
    "potted plant", "bed", "dining table", "toilet", "tv", "laptop", "mouse", "remote", "keyboard", "cell phone",
    "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase", "scissors", "teddy bear",
    "hair drier", "toothbrush"
  ];

  @override
  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      // Recommandé pour le flux caméra
      // options.addDelegate(GpuDelegateV2());

      _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
      print("✅ Modèle Objets (Domestique) chargé.");
    } catch (e) {
      print("❌ Erreur chargement modèle Objets: $e");
    }
  }

  @override
  Future<List<DetectionResult>> predict(dynamic input) async {
    if (_interpreter == null) return [];
    if (input is! CameraImage) throw Exception("DomesticModelService attend une CameraImage");

    // 1. Conversion CameraImage (YUV) -> Tensor RGB
    final inputTensor = _cameraImageToFloat32List(input);

    // 2. Inférence
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final outputBuffer = List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);
    _interpreter!.run(inputTensor, outputBuffer);

    // 3. Post-Processing
    return YoloPostProcessor.process(outputBuffer, _labels);
  }

  @override
  void dispose() {
    _interpreter?.close();
  }

  List<dynamic> _cameraImageToFloat32List(CameraImage cameraImage) {
    final float32Bytes = Float32List(1 * _inputSize * _inputSize * 3);
    int pixelIndex = 0;
    final double xScale = cameraImage.width / _inputSize;
    final double yScale = cameraImage.height / _inputSize;
    final yPlane = cameraImage.planes[0].bytes;
    final uPlane = cameraImage.planes[1].bytes;
    final vPlane = cameraImage.planes[2].bytes;
    final int yRowStride = cameraImage.planes[0].bytesPerRow;
    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;

    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final int sourceX = (x * xScale).floor();
        final int sourceY = (y * yScale).floor();
        final int uvIndex = uvPixelStride * (sourceX >> 1) + uvRowStride * (sourceY >> 1);
        final int index = sourceY * yRowStride + sourceX;

        final yp = yPlane[index];
        final up = uPlane[uvIndex];
        final vp = vPlane[uvIndex];

        int r = (yp + vp * 1436 / 1024 - 179).round();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
        int b = (yp + up * 1814 / 1024 - 227).round();

        float32Bytes[pixelIndex++] = r.clamp(0, 255) / 255.0;
        float32Bytes[pixelIndex++] = g.clamp(0, 255) / 255.0;
        float32Bytes[pixelIndex++] = b.clamp(0, 255) / 255.0;
      }
    }
    return float32Bytes.reshape([1, _inputSize, _inputSize, 3]);
  }
}