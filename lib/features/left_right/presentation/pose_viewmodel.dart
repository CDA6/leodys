import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../domain/entity/body_part_entity.dart';
import '../domain/usecase/detect_pose_usecase.dart';


class PoseViewModel extends ChangeNotifier {
  final DetectPoseUseCase _detectPoseUseCase;

  List<BodyPoint> points = [];
  String debugText = "Initialisation...";
  bool _isDetecting = false;

  PoseViewModel(this._detectPoseUseCase);

  // Reçoit l'image ET l'orientation capteur depuis l'écran
  Future<void> onFrameReceived(CameraImage image, int sensorOrientation) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final result = await _detectPoseUseCase(image, sensorOrientation: sensorOrientation);

      points = result;
      debugText = result.isNotEmpty
          ? "Points: ${result.length} (${(result[0].confidence * 100).toInt()}%)"
          : "Recherche...";

      notifyListeners();
    } catch (e) {
      debugText = "Erreur: $e";
      notifyListeners();
    } finally {
      _isDetecting = false;
    }
  }

  void reset() {
    points = [];
    debugText = "Changement caméra...";
    notifyListeners();
  }
}