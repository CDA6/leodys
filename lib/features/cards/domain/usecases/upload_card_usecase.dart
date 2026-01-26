import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/features/cards/data/cards_repository.dart';
import 'package:leodys/features/cards/domain/card_model.dart';

import '../../../../common/errors/failures.dart';

class UploadCardUsecase with UseCaseMixin<void, CardModel>{
  final CardsRepository repository;
  UploadCardUsecase(this.repository);

  @override
  Future<Either<Failure, void>> execute (CardModel card) async {
    final result = await repository.uploadCard(card);
    return result;
  }
}