import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/features/cards/data/cards_repository.dart';
import 'package:leodys/features/cards/domain/card_model.dart';
import 'package:leodys/features/cards/domain/card_update_model.dart';


class UpdateCardUsecase with UseCaseMixin<CardModel, CardUpdateModel>{
  final CardsRepository repository;
  UpdateCardUsecase(this.repository);

  @override
  Future<Either<Failure, CardModel>> execute(CardUpdateModel update) async {
    return await repository.updateCard(update);
  }
}