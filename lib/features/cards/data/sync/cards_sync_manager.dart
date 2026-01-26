import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/local/cards_local_datasource.dart';
import '../datasources/remote/cards_remote_datasource.dart';

class CardSyncManager {
  final CardsLocalDatasource local;
  final CardsRemoteDatasource remote;

  CardSyncManager({
    required this.local,
    required this.remote,
  });

  Future<void> sync() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await pushLocalCards(user.id);
    await pullRemoteCards(user.id);
  }

  // local vers remote (supabase)
  Future<void> pushLocalCards(String userId) async {
    final localCards = await local.getCardsToSync();
    // print(localCards.toString());

    for (final card in localCards) {

      if (card.deleted) {
        print(card.toString());
        await remote.deleteCard(card.id, userId);
        await local.removeCard(card);
        continue;
      }

      await remote.uploadCard(userId, card);

      await local.markAsSynced(card.id);
    }
  }

  // remote (supabase) vers local
  Future<void> pullRemoteCards(String userId) async {
    await remote.pullRemoteCards(userId);
  }
}

