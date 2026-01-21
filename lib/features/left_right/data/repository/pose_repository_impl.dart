import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // Pour Float32List
import 'package:tflite_flutter/tflite_flutter.dart';


import '../../domain/entity/body_part_entity.dart';
import '../../domain/repository/pose_repository.dart';
import '../datasource/pose_datasource.dart';
import '../model/pose_model.dart';

class PoseRepositoryImpl implements PoseRepository {
  final PoseDataSource _dataSource;
  final int _inputSize = 640;

  PoseRepositoryImpl(this._dataSource);

  @override
  Future<List<BodyPoint>> detectPose(dynamic image, {required int sensorOrientation}) async {
    if (image is! CameraImage) return [];

    // SECURITÉ : Vérification des planes (Fix Crash Android Back Camera)
    if (image.planes.length < 3) {
      return [];
    }

    // 1. Conversion avec prise en compte de l'orientation réelle
    var inputTensor = await _convertCameraImageToTensor(image, sensorOrientation);
    if (inputTensor == null) return [];

    // 2. Inférence
    var rawOutput = _dataSource.runInference(inputTensor);
    if (rawOutput == null) return [];

    // 3. Mapping vers entités
    return PoseModel.fromTfliteOutput(rawOutput);
  }

  Future<List<dynamic>?> _convertCameraImageToTensor(CameraImage image, int sensorOrientation) async {
    return await Future(() {
      try {
        final int width = image.width;
        final int height = image.height;

        // --- FIX REDMI / ANDROID : RECUPERATION DES STRIDES ---
        // bytesPerRow peut être plus grand que width (padding mémoire)
        final int yRowStride = image.planes[0].bytesPerRow;
        final int uvRowStride = image.planes[1].bytesPerRow;
        final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;
        // ------------------------------------------------------

        var floatInput = Float32List(1 * _inputSize * _inputSize * 3);

        int cropSize = width < height ? width : height;
        int offsetX = (width - cropSize) ~/ 2;
        int offsetY = (height - cropSize) ~/ 2;

        for (int y = 0; y < _inputSize; y++) {
          for (int x = 0; x < _inputSize; x++) {
            double relX = x / _inputSize;
            double relY = y / _inputSize;

            int cameraX, cameraY;

            // Rotation intelligente
            if (sensorOrientation == 90) {
              cameraX = offsetX + (relY * cropSize).toInt();
              cameraY = offsetY + ((1.0 - relX) * cropSize).toInt();
            } else if (sensorOrientation == 270) {
              cameraX = offsetX + ((1.0 - relY) * cropSize).toInt();
              cameraY = offsetY + (relX * cropSize).toInt();
            } else {
              cameraX = offsetX + (relX * cropSize).toInt();
              cameraY = offsetY + (relY * cropSize).toInt();
            }

            cameraX = cameraX.clamp(0, width - 1);
            cameraY = cameraY.clamp(0, height - 1);

            // --- FIX REDMI : CALCUL DE L'INDEX MÉMOIRE ---
            // On utilise yRowStride au lieu de width pour le plan Y
            final int index = cameraY * yRowStride + cameraX;
            // ---------------------------------------------

            final int uvIndex = (uvPixelStride * (cameraX / 2).floor()) + (uvRowStride * (cameraY / 2).floor());

            // Sécurité pour ne pas sortir du tableau (Crash fréquent sur Redmi)
            if (index >= image.planes[0].bytes.length || uvIndex >= image.planes[1].bytes.length) {
              continue;
            }

            final yVal = image.planes[0].bytes[index];
            final uVal = image.planes[1].bytes[uvIndex];
            final vVal = image.planes[2].bytes[uvIndex];

            // YUV -> RGB
            int r = (yVal + (1.370705 * (vVal - 128))).toInt();
            int g = (yVal - (0.337633 * (uVal - 128)) - (0.698001 * (vVal - 128))).toInt();
            int b = (yVal + (1.732446 * (uVal - 128))).toInt();

            int tensorIndex = (y * _inputSize + x) * 3;
            floatInput[tensorIndex] = r.clamp(0, 255) / 255.0;
            floatInput[tensorIndex + 1] = g.clamp(0, 255) / 255.0;
            floatInput[tensorIndex + 2] = b.clamp(0, 255) / 255.0;
          }
        }
        return floatInput.reshape([1, 640, 640, 3]);
      } catch (e) {
        print("Erreur conversion: $e");
        return null;
      }
    });
  }
}