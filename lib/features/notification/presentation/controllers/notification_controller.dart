import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/referent_entity.dart';
import '../../domain/usecases/send_notification_email.dart';
import '../../domain/usecases/sync_message_history.dart';
import '../../domain/usecases/sync_referents.dart';

class NotificationController extends ChangeNotifier{
  final NotificationRepository repository;
  final SendNotificationEmail sendNotificationEmail;
  final SyncMessageHistory syncMessageHistory;
  final SyncReferents syncReferents;

  NotificationController(this.repository, this.sendNotificationEmail, this.syncMessageHistory, this.syncReferents);

  List<ReferentEntity> referents = [];
  List<MessageEntity> messages = [];
  bool isLoading = false;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners(); // Affiche un loader

    // On récupère les listes depuis le repository (Hive)
    referents = await repository.getReferents();
    messages = await repository.getMessageHistory();

    isLoading = false;
    notifyListeners(); // Affiche les données
  }

  Future<void> addReferent(String name, String email, String category, String userId) async {
    if (userId.isEmpty) return;

    final newRef = ReferentEntity(
      id:  const Uuid().v4(),
      name: name,
      email: email,
      role: "Contact",
      category: category,
      userId: userId,
    );

    // 1. Sauvegarde locale pour réactivité immédiate
    await repository.addReferent(newRef);

    // 2. Sauvegarde distante (Supabase)
    try {
      await repository.saveRemoteReferent(newRef);
    } catch (e) {
      // Optionnel: Gérer ici une file d'attente de synchro si échec (mode hors-ligne)
      print("Erreur synchro remote referent: $e");
    }

    await loadData();
  }

  Future<void> removeReferent(String id) async {
    await repository.deleteReferent(id);
    await repository.deleteRemoteReferent(id);
    notifyListeners();
  }

  Future<void> notify(ReferentEntity referent, String userId) {
    return sendNotificationEmail.call(
      referent: referent,
      subject: "Alerte de suivi Leodys",
      body: "Bonjour ${referent.name},\nJe souhaite vous contacter concernant...",
      userId: userId
    );
  }

  Future<void> sendMessage({required ReferentEntity referent, required String subject, required String body, required String userId}) async {
    await sendNotificationEmail.call(referent: referent, subject: subject, body: body,  userId: userId,);
  }

  Future<void> synchronizeMessageHistory() async {
    await syncMessageHistory.call();
    await loadData();
  }

  Future<void> synchronizeReferents() async {
    await syncReferents.call();
    notifyListeners();
    await loadData();
  }
}
