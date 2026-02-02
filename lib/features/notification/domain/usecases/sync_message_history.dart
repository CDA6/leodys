import '../../../../common/utils/internet_util.dart';
import '../repositories/notification_repository.dart';

/// synchroniser l'historique des messages entre le stockage local et distant.
class SyncMessageHistory {
  final NotificationRepository repository;

  SyncMessageHistory(this.repository);

  Future<void> call() async {
    // 1. Vérification de la connexion
    if (!InternetUtil.isConnected) {
      print("LOG: Synchro messages annulée (Hors-ligne)");
      return;
    }
    print("LOG: Démarrage de la synchronisation de l'historique des messages...");

    final localMessages = await repository.getMessageHistory();
    final remoteMessages = await repository.getRemoteMessageHistory();

    final localMessageIds = localMessages.map((msg) => msg.id).toSet();
    final remoteMessageIds = remoteMessages.map((msg) => msg.id).toSet();

    // 1. Ajouter les messages distants manquants au local
    for (var remoteMsg in remoteMessages) {
      if (!localMessageIds.contains(remoteMsg.id)) {
        await repository.saveLocalMessage(remoteMsg);
        print("LOG: Message distant ajouté au local: ${remoteMsg.id} et ${remoteMsg.userId}");
      }
    }

    // 2. Ajouter les messages locaux manquants au distant

    for (var localMsg in localMessages) {
      if (!remoteMessageIds.contains(localMsg.id)) {
        await repository.saveRemoteMessage(localMsg);
        print("LOG: Message local ajouté au distant: ${localMsg.id}");
      }
    }
    print("LOG: Synchronisation de l'historique des messages terminée.");
  }
}