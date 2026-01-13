import '../entities/message_entity.dart';
import '../entities/referent_entity.dart';

abstract class NotificationRepository {
  Future<void> sendEmailToReferent({required Referent referent, required String subject, required String body});
  Future<List<Referent>> getReferents();
  Future<void> addReferent(Referent referent);
  Future<void> deleteReferent(String id);
  Future<List<MessageEntity>> getMessageHistory();
  Future<void> saveMessage(MessageEntity message);
}