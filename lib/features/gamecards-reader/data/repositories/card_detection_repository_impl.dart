import 'dart:io';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_detection_repository.dart';
import 'package:leodys/features/gamecards-reader/data/models/card_model.dart';
import '../datasource/card_model_datasource.dart';

class CardDetectionRepositoryImpl implements CardDetectionRepository {
  final CardModelDatasource _service;

  CardDetectionRepositoryImpl({required CardModelDatasource service})
      : _service = service;

  @override
  Future<void> loadModel() async {
    await _service.loadModel();
  }

  @override
  Future<List<CardEntity>> detectCards(File imageFile) async {

    final rawDetections = await _service.predict(imageFile);

    final models = rawDetections.map((detection) {
      return CardModel(
        label: detection.label,
        confidence: detection.confidence,
      );
    }).toList();

    final entities = models.map((model) => model.toEntity()).toList();

    return _deduplicateCards(entities);
  }

  List<CardEntity> _deduplicateCards(List<CardEntity> cards) {
    final Map<String, CardEntity> bestCards = {};

    for (var card in cards) {
      final key = '${card.value}_${card.suit}';

      if (!bestCards.containsKey(key) ||
          card.confidence > bestCards[key]!.confidence) {
        bestCards[key] = card;
      }
    }

    return bestCards.values.toList();
  }

  @override
  void dispose() {
    _service.dispose();
  }
}