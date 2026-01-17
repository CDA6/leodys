import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leodys/common/domain/usecase.dart';
import '../../domain/entities/ocr_result.dart';

abstract class BaseOcrViewModel extends ChangeNotifier {
  final UseCase<OcrResult, File> recognizeTextUseCase;

  File? _selectedImage;
  OcrResult? _ocrResult;
  bool _isProcessing = false;
  String? _errorMessage;

  BaseOcrViewModel({required this.recognizeTextUseCase});

  // Getters
  File? get selectedImage => _selectedImage;
  OcrResult? get ocrResult => _ocrResult;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  bool get canAnalyze => _selectedImage != null && !_isProcessing;

  // Methods
  Future<void> pickImageFromCamera() async => _pickImage(ImageSource.camera);
  Future<void> pickImageFromGallery() async => _pickImage(ImageSource.gallery);
  void clearImage() {
    _selectedImage = null;
    _ocrResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _ocrResult = null;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la sélection de l\'image: $e';
      notifyListeners();
    }
  }

  Future<void> analyzeImage() async {
    if (_selectedImage == null) return;

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    final result = await recognizeTextUseCase(_selectedImage!);

    result.fold(
          (failure) {
        _errorMessage = failure.message;
        _ocrResult = null;
        print('❌ Erreur: ${failure.message}');
      },
          (ocrResult) {
        _ocrResult = ocrResult;
        _errorMessage = null;
      },
    );

    _isProcessing = false;
    notifyListeners();
  }
}
