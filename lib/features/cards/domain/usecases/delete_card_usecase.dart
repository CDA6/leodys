import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/features/cards/data/cards_repository.dart';
import 'package:leodys/features/cards/domain/usecases/sync_cards_usecase.dart';
import 'package:leodys/features/cards/domain/card_model.dart';

import '../../../../common/errors/failures.dart';

class DeleteCardUsecase with UseCaseMixin<void, CardModel>{
  final CardsRepository repository;
  final SyncCardsUsecase syncManager;
  DeleteCardUsecase(this.repository, this.syncManager);

  @override
  Future<Either<Failure, void>> execute (CardModel card) async {
    final result = await repository.markLocalCardAsDeleted(card.id);

    await syncManager.call(null);

    return result;
  }
}