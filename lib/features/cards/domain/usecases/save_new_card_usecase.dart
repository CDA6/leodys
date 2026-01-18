import 'dart:io';

import 'package:leodys/features/cards/domain/card_model.dart';

import '../../data/cards_repository.dart';
import '../../data/sync/cards_sync_manager.dart';

class SaveNewCardUsecase {
  final CardsRepository repository;
  final CardSyncManager syncManager;

  SaveNewCardUsecase(this.repository, this.syncManager);

  Future<CardModel> call(List<File> imagesPaths, String name) async {
    final newCard = await repository.saveNewCard(imagesPaths, name);
    await syncManager.sync();

    return newCard;
  }
}