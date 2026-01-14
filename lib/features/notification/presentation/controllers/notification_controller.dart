import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/referent_entity.dart';

class NotificationController {
  final NotificationRepository repository;
  NotificationController(this.repository);
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
    return repository.sendEmailToReferent(
      referent: referent,
      subject: "Alerte de suivi Leodys",
      body: "Bonjour ${referent.name},\nJe souhaite vous contacter concernant...",
    );
  }

  Future<void> sendMessage({required ReferentEntity referent, required String subject, required String body}) async {
    // 1. Envoi réel
    await repository.sendEmailToReferent(referent: referent, subject: subject, body: body);

    // 2. Sauvegarde dans l'historique
    final message = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      referentId: referent.id,
      referentName: referent.name,
      subject: subject,
      body: body,
      sentAt: DateTime.now(),
    );
    await repository.saveMessage(message);
  }
}
