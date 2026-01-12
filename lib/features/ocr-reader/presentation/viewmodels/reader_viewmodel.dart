import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/usecases/recognize_text_usecase.dart';
import '../../../../core/enums/text_type.dart';

class ReaderViewModel extends ChangeNotifier {
  final RecognizeTextUseCase recognizeTextUseCase;

  ReaderViewModel({required this.recognizeTextUseCase});

  File? _selectedImage;
  OcrResult? _ocrResult;
  bool _isProcessing = false;
  TextType _selectedTextType = TextType.printed;
  String? _errorMessage;

  File? get selectedImage => _selectedImage;
  OcrResult? get ocrResult => _ocrResult;
  bool get isProcessing => _isProcessing;
  TextType get selectedTextType => _selectedTextType;
  String? get errorMessage => _errorMessage;

  void setTextType(TextType type) {
    _selectedTextType = type;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
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

        await processImage();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la sélection de l\'image: $e';
      notifyListeners();
    }
  }

  Future<void> processImage() async {
    if (_selectedImage == null) return;

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    final result = await recognizeTextUseCase(
      image: _selectedImage!,
      textType: _selectedTextType,
    );

    result.fold(
          (failure) {
        _errorMessage = failure.message;
        _ocrResult = null;
        print('❌ Erreur: ${failure.message}');
      },
          (ocrResult) {
        _ocrResult = ocrResult;
        _errorMessage = null;
        print('✅ Texte extrait (${ocrResult.text.length} caractères): ${ocrResult.text}');
      },
    );

    _isProcessing = false;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    _ocrResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}