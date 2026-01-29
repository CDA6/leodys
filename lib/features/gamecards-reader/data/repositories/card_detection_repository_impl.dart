import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:leodys/common/mixins/repository_mixin.dart';

import '../../../../common/errors/failures.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_detection_repository.dart';
import 'package:leodys/features/gamecards-reader/data/models/card_model.dart';
import '../datasource/card_model_datasource.dart';

class CardDetectionRepositoryImpl with RepositoryMixin implements CardDetectionRepository {
  final CardModelDatasource _service;

  CardDetectionRepositoryImpl({required CardModelDatasource service})
      : _service = service;

  @override
  Future<void> loadModel() async {
    await _service.loadModel();
  }

  @override
  Future<Either<Failure, List<CardEntity>>> detectCards(File imageFile) async {
    return execute('recognizePrintedText', () async {
      try {
        final rawDetections = await _service.predict(imageFile);

        final models = rawDetections.map((detection) {
          return CardModel(
            label: detection.label,
            confidence: detection.confidence,
          );
        }).toList();

        final entities = models.map((model) => model.toEntity()).toList();

        return Right(_deduplicateCards(entities));
      } on Exception catch (e) {
        return Left(OCRFailure('Erreur ML Kit: $e'));
      }
    });
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