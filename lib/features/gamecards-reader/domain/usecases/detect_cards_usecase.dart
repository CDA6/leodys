import 'dart:io';
import '../entities/card_entity.dart';
import '../repositories/card_detection_repository.dart';

class DetectCardsUseCase {
  final CardDetectionRepository repository;

  DetectCardsUseCase({required this.repository});

  Future<List<CardEntity>> call(File imageFile) async {
    return await repository.detectCards(imageFile);
  }
}