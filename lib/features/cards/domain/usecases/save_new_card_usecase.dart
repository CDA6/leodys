import 'dart:io';

import 'package:leodys/features/cards/domain/card_model.dart';

import '../../data/cards_repository.dart';

class SaveNewCardUsecase {
  final CardsRepository repository;

  SaveNewCardUsecase(this.repository);

  Future<CardModel> call(List<File> imagesPaths, String name) async {
    return await repository.saveNewCard(imagesPaths, name);
  }
}