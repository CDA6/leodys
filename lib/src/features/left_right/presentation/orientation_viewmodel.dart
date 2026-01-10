import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../domain/entity/body_part_entity.dart';
import '../domain/usecase/detect_side_usecase.dart';

class OrientationViewModel extends ChangeNotifier {
  final DetectSideUsecase _usecase;

  BodyPart? result;
  bool _isProcessing = false; // Pour éviter de surcharger le processeur

  OrientationViewModel(this._usecase);

  Future<void> onFrameAvailable(Uint8List bytes, int h, int w, bool isFront) async {
    if (_isProcessing) return; // On saute la frame si on est déjà occupé

    _isProcessing = true;

    // Appel du UseCase en temps réel
    result = await _usecase.execute(bytes, h, w, isFront);

    notifyListeners();
    _isProcessing = false;
  }
}