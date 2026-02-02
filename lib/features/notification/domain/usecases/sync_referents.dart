import '../../../../common/utils/internet_util.dart';
import '../repositories/notification_repository.dart';

class SyncReferents {
  final NotificationRepository repository;

  SyncReferents(this.repository);

  Future<void> call() async {
    // 1. Vérifier la connexion internet avant tout
    if (!InternetUtil.isConnected) {
      print("LOG: Synchronisation annulée : Pas de connexion internet.");
      return;
    }
    print("LOG: Démarrage de la synchronisation des référents...");

    final localRefs = await repository.getReferents();
    final remoteRefs = await repository.getRemoteReferents();

    final localIds = localRefs.map((r) => r.id).toSet();
    final remoteIds = remoteRefs.map((r) => r.id).toSet();

    for (var remoteRef in remoteRefs) {
      if (!localIds.contains(remoteRef.id)) {
        await repository.addReferent(remoteRef);
        print("LOG: Référent distant ajouté au local: ${remoteRef.name}");
      }
    }

    // 2. Local -> Distant (Ajouter ce qui manque sur Supabase)
    for (var localRef in localRefs) {
      if (!remoteIds.contains(localRef.id)) {
        await repository.saveRemoteReferent(localRef);
        print("LOG: Référent local envoyé au distant: ${localRef.name}");
      }
    }
    print("LOG: Synchronisation des référents terminée.");
  }
}