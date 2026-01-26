import 'package:dartz/dartz.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';

import '../../../../common/errors/failures.dart';
import '../../data/cards_repository.dart';
import 'sync_cards_usecase.dart';
import '../card_model.dart';

class GetLocalUserCardsUsecase with UseCaseMixin<List<CardModel>, void>{
  final CardsRepository repository;
  final SyncCardsUsecase syncManager;

  GetLocalUserCardsUsecase(this.repository, this.syncManager);

  @override
  Future<Either<Failure, List<CardModel>>> execute(void _) async {
    final cards = await repository.getLocalUserCards();
    await syncManager.call(null);

    return cards;
  }
}