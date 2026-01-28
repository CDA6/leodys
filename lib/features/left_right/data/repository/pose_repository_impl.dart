import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../domain/entity/body_part_entity.dart';
import '../../domain/repository/pose_repository.dart';
import '../datasource/pose_datasource.dart';
import '../model/pose_model.dart';

class PoseRepositoryImpl implements PoseRepository {
  final PoseDataSource _dataSource;
  final int _inputSize = 640; // taille attendue par le modele yolo

  PoseRepositoryImpl(this._dataSource);

  @override
  Future<List<BodyPoint>> detectPose(
    dynamic image, {
    required int sensorOrientation,
  }) async {
    // on verifie qu'on a bien une image camera avec les bons plans
    if (image is! CameraImage || image.planes.length < 3) return [];

    // conversion yuv -> rgb
    var inputTensor = await _convertCameraImageToTensor(
      image,
      sensorOrientation,
    );
    if (inputTensor == null) return [];
    //lancement inférence
    var rawOutput = _dataSource.runInference(inputTensor);
    if (rawOutput == null) return [];

    // sortie tenseur vers BodyPoint
    return PoseModel.fromTfliteOutput(rawOutput);
  }

  Future<List<dynamic>?> _convertCameraImageToTensor(
    CameraImage image,
    int sensorOrientation,
  ) async {
    return await Future(() {
      try {
        //dimensions brutes (ex : 1920*1080
        final int width = image.width;
        final int height = image.height;

        // nombre de bytes par ligne pour le plan Y (luminance)
        // souvent != width à cause de l'alignement memoire du capteur
        final int yRowStride = image.planes[0].bytesPerRow;

        // pareil mais pour les plans U et V (chrominance)
        // generalement la moitié de yRowStride car U/V sont sous-échantillonnés
        final int uvRowStride = image.planes[1].bytesPerRow;

        // espacement entre 2 pixels UV consécutifs en memoire
        // vaut 1 pour NV21 (format standard Android), 2 pour certains autres formats (uuuu,vvvvv ou uvuvuvuv,vuvuvuvuvu)
        final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

        // on prépare le tableau qui va contenir l'image en RGB normalisé
        var floatInput = Float32List(1 * _inputSize * _inputSize * 3);

        // on calcule le crop(plus petit cote) pour garder un carré au centre de l'image
        int cropSize = width < height ? width : height;
        int offsetX = (width - cropSize) ~/ 2;
        int offsetY = (height - cropSize) ~/ 2;

        // pour chaque pixel de l'image finale (640x640)
        for (int y = 0; y < _inputSize; y++) {
          for (int x = 0; x < _inputSize; x++) {
            // position relative en pourcentage
            double relX = x / _inputSize;
            double relY = y / _inputSize;

            int cameraX, cameraY;

            // maintenant on calcule quel pixel ça correspond dans l'image source
            if (sensorOrientation == 90) {
              cameraX = offsetX + (relY * cropSize).toInt();
              cameraY = offsetY + ((1.0 - relX) * cropSize).toInt();
            } else if (sensorOrientation == 270) {
              cameraX = offsetX + ((1.0 - relY) * cropSize).toInt();
              cameraY = offsetY + (relX * cropSize).toInt();
            } else {
              // pas de rotation
              cameraX = offsetX + (relX * cropSize).toInt();
              cameraY = offsetY + (relY * cropSize).toInt();
            }

            // on s'assure de rester dans les limites de l'image
            cameraX = cameraX.clamp(0, width - 1);
            cameraY = cameraY.clamp(0, height - 1);

            // calcul des index pour lire les valeurs YUV
            //calcul de l'index d'un tableau à plat
            final int index = cameraY * yRowStride + cameraX;
            final int uvIndex =
                (uvPixelStride * (cameraX / 2).floor()) +
                (uvRowStride * (cameraY / 2).floor());

            // securité au cas ou on depasse
            if (index >= image.planes[0].bytes.length ||
                uvIndex >= image.planes[1].bytes.length) {
              continue;
            }

            // lecture des composantes YUV
            final yVal = image.planes[0].bytes[index];
            final uVal = image.planes[1].bytes[uvIndex];
            final vVal = image.planes[2].bytes[uvIndex];

            // conversion des bytes YUV(0 a 255) vers YUV(-128 a 127) puis vers RGB(0-255)avec les coefs standards
            int r = (yVal + (1.370705 * (vVal - 128))).toInt();
            int g =
                (yVal - (0.337633 * (uVal - 128)) - (0.698001 * (vVal - 128)))
                    .toInt();
            int b = (yVal + (1.732446 * (uVal - 128))).toInt();

            // on ecrit dans le tenseur en normalisant [0-255] -> [0-1]
            int tensorIndex = (y * _inputSize + x) * 3;
            floatInput[tensorIndex] = r.clamp(0, 255) / 255.0;
            floatInput[tensorIndex + 1] = g.clamp(0, 255) / 255.0;
            floatInput[tensorIndex + 2] = b.clamp(0, 255) / 255.0;
          }
        }
        // on reshape pour avoir la forme [1, 640, 640, 3] attendue par yolo
        return floatInput.reshape([1, 640, 640, 3]);
      } catch (e) {
        return null;
      }
    });
  }
}
