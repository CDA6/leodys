import '../../data/cards_repository.dart';
import '../../data/sync/cards_sync_manager.dart';
import '../card_model.dart';

class GetLocalUserCardsUsecase {
  final CardsRepository repository;
  final CardSyncManager syncManager;

  GetLocalUserCardsUsecase(this.repository, this.syncManager);

  Future<List<CardModel>> call() async {
    final cards = await repository.getLocalUserCards();
    await syncManager.sync();

    return cards;
  }
}