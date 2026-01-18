import 'dart:io';

import 'package:leodys/features/cards/data/cards_repository.dart';
import 'package:leodys/features/cards/data/sync/cards_sync_manager.dart';
import 'package:leodys/features/cards/domain/card_model.dart';

class DeleteCardUsecase {
  final CardsRepository repository;
  final CardSyncManager syncManager;
  DeleteCardUsecase(this.repository, this.syncManager);

  Future<void> call (CardModel card) async {
    await repository.markLocalCardAsDeleted(card.id);

    await syncManager.sync();
  }
}