import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/usecases/detect_cards_usecase.dart';

class GamecardReaderViewModel extends ChangeNotifier {
  final DetectCardsUseCase _detectCardsUseCase;

  File? _selectedImage;
  List<CardEntity> _detectedCards = [];
  bool _isProcessing = false;
  String? _errorMessage;

  GamecardReaderViewModel({required DetectCardsUseCase detectCardsUseCase})
      : _detectCardsUseCase = detectCardsUseCase;

  // Getters
  File? get selectedImage => _selectedImage;
  List<CardEntity> get detectedCards => _detectedCards;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  bool get canAnalyze => _selectedImage != null && !_isProcessing;

  Future<void> pickImageFromCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      await _pickImage(ImageSource.camera);
    } else if (status.isPermanentlyDenied) {
      _errorMessage = 'Accédez aux paramètres pour activer la caméra';
      notifyListeners();
      await openAppSettings();
    } else {
      _errorMessage = 'Permission caméra refusée';
      notifyListeners();
    }
  }

  Future<void> pickImageFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _detectedCards = [];
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur sélection image: $e';
      notifyListeners();
    }
  }

  Future<void> analyzeImage() async {
    if (_selectedImage == null) return;

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _detectCardsUseCase(_selectedImage!);
      result.fold(
            (failure) {
          _errorMessage = 'Erreur analyse: $failure';
          _detectedCards = [];
        },
            (cards) {
          _detectedCards = cards;
        },
      );

      if (_detectedCards.isEmpty) {
        _errorMessage = 'Aucune carte détectée';
      }
    } catch (e) {
      _errorMessage = 'Erreur analyse: $e';
      _detectedCards = [];
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}