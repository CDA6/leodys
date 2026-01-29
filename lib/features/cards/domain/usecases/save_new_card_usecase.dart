import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/features/cards/domain/card_model.dart';
import 'package:leodys/features/cards/domain/usecases/params/save_new_card_params.dart';

import '../../../../common/errors/failures.dart';
import '../../data/cards_repository.dart';
import 'sync_cards_usecase.dart';

class SaveNewCardUsecase with UseCaseMixin<CardModel, SaveNewCardParams>{
  final CardsRepository repository;
  final SyncCardsUsecase sync;

  SaveNewCardUsecase(this.repository, this.sync);

  @override
  Future<Either<Failure, CardModel>> execute(SaveNewCardParams params) async {
    final imagesPaths = params.imageFiles;
    final name = params.name;

    final newCard = await repository.saveNewCard(imagesPaths, name);
    await sync.call(null);

    return newCard;
  }
}