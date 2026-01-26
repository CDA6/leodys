import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // pour Float32List
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../domain/entity/body_part_entity.dart';
import '../../domain/repository/pose_repository.dart';
import '../datasource/pose_datasource.dart';
import '../model/pose_model.dart';

class PoseRepositoryImpl implements PoseRepository {
  final PoseDataSource _dataSource;
  final int _inputSize = 640; // taille attendue par yolo v8/11

  PoseRepositoryImpl(this._dataSource);

  @override
  Future<List<BodyPoint>> detectPose(dynamic image, {required int sensorOrientation}) async {
    // verif basique type image
    if (image is! CameraImage) return [];

    // secu crash android : verif qu'on a bien les 3 couches yuv (y, u, v)
    // sur certains tel ca arrive incomplet et ca fait tout peter
    if (image.planes.length < 3) {
      return [];
    }

    // 1. transforme l'image brute en tenseur pour l'ia (le gros morceau)
    var inputTensor = await _convertCameraImageToTensor(image, sensorOrientation);
    if (inputTensor == null) return [];

    // 2. demande a tflite de reflechir
    var rawOutput = _dataSource.runInference(inputTensor);
    if (rawOutput == null) return [];

    // 3. convertit la bouillie de chiffres en points lisibles (main, nez...)
    return PoseModel.fromTfliteOutput(rawOutput);
  }

  // la grosse fonction matheuse qui fait ramer si mal optimisée
  Future<List<dynamic>?> _convertCameraImageToTensor(CameraImage image, int sensorOrientation) async {
    return await Future(() {
      try {
        final int width = image.width;
        final int height = image.height;

        // fix redmi/android : faut recup le "vrai" saut de ligne en memoire (stride)
        // sinon l'image est toute décalée ou ca crash direct
        final int yRowStride = image.planes[0].bytesPerRow;
        final int uvRowStride = image.planes[1].bytesPerRow;
        final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

        // tableau géant pour les 640x640 pixels x 3 couleurs
        var floatInput = Float32List(1 * _inputSize * _inputSize * 3);

        // calcul pour centrer l'image (crop) sans la deformer
        int cropSize = width < height ? width : height;
        int offsetX = (width - cropSize) ~/ 2;
        int offsetY = (height - cropSize) ~/ 2;

        // on parcourt chaque pixel de l'image cible (640x640)
        for (int y = 0; y < _inputSize; y++) {
          for (int x = 0; x < _inputSize; x++) {
            double relX = x / _inputSize;
            double relY = y / _inputSize;

            int cameraX, cameraY;

            // rotation : on doit piocher le pixel au bon endroit dans l'image source
            // selon comment on tient le tel (90 ou 270 degrés souvent)
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

            // on reste dans les bornes
            cameraX = cameraX.clamp(0, width - 1);
            cameraY = cameraY.clamp(0, height - 1);

            // calcul savant pour trouver le pixel dans le tableau d'octets yuv
            // important d'utiliser yRowStride ici
            final int index = cameraY * yRowStride + cameraX;
            final int uvIndex = (uvPixelStride * (cameraX / 2).floor()) + (uvRowStride * (cameraY / 2).floor());

            // anti-crash : si on sort du tableau on zappe ce pixel (fix redmi frequent)
            if (index >= image.planes[0].bytes.length || uvIndex >= image.planes[1].bytes.length) {
              continue;
            }

            // recupere les valeurs brutes
            final yVal = image.planes[0].bytes[index];
            final uVal = image.planes[1].bytes[uvIndex];
            final vVal = image.planes[2].bytes[uvIndex];

            // formule magique yuv vers rgb
            int r = (yVal + (1.370705 * (vVal - 128))).toInt();
            int g = (yVal - (0.337633 * (uVal - 128)) - (0.698001 * (vVal - 128))).toInt();
            int b = (yVal + (1.732446 * (uVal - 128))).toInt();

            // on remplit le tableau final en normalisant (0.0 a 1.0)
            int tensorIndex = (y * _inputSize + x) * 3;
            floatInput[tensorIndex] = r.clamp(0, 255) / 255.0;
            floatInput[tensorIndex + 1] = g.clamp(0, 255) / 255.0;
            floatInput[tensorIndex + 2] = b.clamp(0, 255) / 255.0;
          }
        }
        // format tflite : [1, 640, 640, 3]
        return floatInput.reshape([1, 640, 640, 3]);
      } catch (e) {
        print("Erreur conversion: $e");
        return null;
      }
    });
  }
}