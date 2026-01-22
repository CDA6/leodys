import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/common/utils/app_logger.dart';
import 'package:leodys/features/ocr-reader/domain/entities/ocr_result.dart';

abstract class BaseOcrViewModel extends ChangeNotifier {
  final UseCaseMixin<OcrResult, File> recognizeTextUseCase;

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
      AppLogger().debug('[ViewModel] Sélection image source: $source');

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
        AppLogger().info('Image sélectionnée: ${pickedFile.path}');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la sélection de l\'image: $e';
      AppLogger().error('Erreur sélection image: $e');
      notifyListeners();
    }
  }

  Future<void> analyzeImage() async {
    if (_selectedImage == null) return;

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await recognizeTextUseCase(_selectedImage!).timeout(const Duration(seconds: 15));

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          AppLogger().error("OCR Error: ${failure.message}");
        },
        (ocrResult) {
          _ocrResult = ocrResult;
          AppLogger().info("OCR Success: ${ocrResult.text.length} caractères");
        },
      );

    } on TimeoutException {
      _errorMessage = 'Timeout: L\'analyse prend trop de temps. Vérifiez votre connexion.';
      AppLogger().error("OCR Timeout");
    } on Exception catch (e) {
      _errorMessage = 'Erreur inattendue: ${e.toString()}';
      AppLogger().error("OCR Exception: ${e.toString()}", e);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
