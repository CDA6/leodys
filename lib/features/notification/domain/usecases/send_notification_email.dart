import '../entities/message_entity.dart';
import '../entities/referent_entity.dart';
import '../repositories/notification_repository.dart';

/// Ce use case encapsule la logique métier complète d'envoi d'un e-mail
/// et d'archivage du message, à la fois localement et à distance.
class SendNotificationEmail {
  final NotificationRepository repository;

  SendNotificationEmail(this.repository);

  Future<void> call({required ReferentEntity referent, required String subject, required String body}) async {
    // 1. Envoi réel via le repositories (qui déléguerà à la nouvelle datasource d'envoi d'e-mails)
    await repository.sendEmailToExternalService(referent: referent, subject: subject, body: body);

    // 2. Sauvegarde dans l'historique local via le repositories
    final message = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      referentId: referent.id,
      referentName: referent.name,
      subject: subject,
      body: body,
      sentAt: DateTime.now(),
    );
    await repository.saveLocalMessage(message);

    // 3. Sauvegarde dans l'historique distant (Supabase) via le repositories
    // L'implémentation concrète de 'saveRemoteMessage' sera gérée par NotificationRemoteDataSourceImpl.
    await repository.saveRemoteMessage(message);
  }
}