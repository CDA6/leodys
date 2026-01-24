import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/referent_entity.dart';
import '../../domain/usecases/send_notification_email.dart';
import '../../domain/usecases/sync_message_history.dart';

class NotificationController {
  final NotificationRepository repository;
  final SendNotificationEmail sendNotificationEmail;
  final SyncMessageHistory syncMessageHistory;

  NotificationController(this.repository, this.sendNotificationEmail, this.syncMessageHistory);

  Future<List<MessageEntity>> fetchHistory() => repository.getMessageHistory();
  Future<List<ReferentEntity>> fetchReferents() => repository.getReferents();

  Future<void> addReferent(String name, String email, String category) {
    final newRef = ReferentEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: "Contact",
      category: category,
    );
    return repository.addReferent(newRef);
  }

  Future<void> removeReferent(String id) => repository.deleteReferent(id);

  Future<void> notify(ReferentEntity referent) {
    return sendNotificationEmail.call(
      referent: referent,
      subject: "Alerte de suivi Leodys",
      body: "Bonjour ${referent.name},\nJe souhaite vous contacter concernant...",
    );
  }

  Future<void> sendMessage({required ReferentEntity referent, required String subject, required String body}) async {
    await sendNotificationEmail.call(referent: referent, subject: subject, body: body);
  }

  Future<void> synchronizeMessageHistory() async {
    await syncMessageHistory.call();
  }
}
