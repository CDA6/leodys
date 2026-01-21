import 'dart:async';
import 'package:leodys/features/cards/data/cards_repository.dart';
import 'package:leodys/features/cards/domain/card_model.dart';
import 'package:leodys/features/cards/domain/card_update_model.dart';


class UpdateCardUsecase {
  final CardsRepository repository;
  UpdateCardUsecase(this.repository);

  Future<CardModel?> execute(CardUpdateModel update) async {
    try {
      return await repository.updateCard(update);
    } catch (e) {
      return null;
    }
  }
}