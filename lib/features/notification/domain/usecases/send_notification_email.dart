import 'package:uuid/uuid.dart';

import '../entities/message_entity.dart';
import '../entities/referent_entity.dart';
import '../repositories/notification_repository.dart';

class SendNotificationEmail {
  final NotificationRepository repository;

  SendNotificationEmail(this.repository);

  Future<void> call({required ReferentEntity referent, required String subject, required String body,   required String userId,}) async {

    await repository.sendEmailToExternalService(referent: referent, subject: subject, body: body);

    // Sauvegarde dans l'historique local via le repositories
    final message = MessageEntity(
      id:  const Uuid().v4(),
      referentId: referent.id,
      referentName: referent.name,
      subject: subject,
      body: body,
      sentAt: DateTime.now(),
      userId: userId,
    );

    await repository.saveLocalMessage(message);
    await repository.saveRemoteMessage(message);
  }
}