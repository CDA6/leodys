import '../entities/message_entity.dart';
import '../entities/referent_entity.dart';

abstract class NotificationRepository {

  Future<void> sendEmailToExternalService({required ReferentEntity referent, required String subject, required String body});
  Future<List<ReferentEntity>> getReferents();
  Future<void> addReferent(ReferentEntity referent);
  Future<void> deleteReferent(String id);
  Future<List<MessageEntity>> getMessageHistory();
  Future<List<MessageEntity>> getRemoteMessageHistory();
  Future<void> saveLocalMessage(MessageEntity message);
  Future<void> saveRemoteMessage(MessageEntity message);
}