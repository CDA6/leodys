import 'dart:io';

import 'package:leodys/features/cards/data/cards_repository.dart';
import 'package:leodys/features/cards/domain/card_model.dart';

class UploadCardUsecase {
  final CardsRepository repository;
  UploadCardUsecase(this.repository);

  Future<void> call (CardModel card, String userId) async {
    await repository.uploadCard(card, userId);
  }
}