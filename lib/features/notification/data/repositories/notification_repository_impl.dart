import 'package:uuid/uuid.dart';

import '../../domain/entities/message_entity.dart';
import '../../domain/entities/referent_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';
import '../datasources/email_sender_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;
  final NotificationRemoteDataSource remoteMessageDataSource;
  final EmailSenderDataSource emailSenderDataSource;

  NotificationRepositoryImpl({
    required this.localDataSource,
    required this.remoteMessageDataSource,
    required this.emailSenderDataSource
  });


  @override
  Future<List<ReferentEntity>> getReferents() async {
    final localData = await localDataSource.getReferents();
    return localData;
  }

  @override
  Future<void> addReferent(ReferentEntity referent) => localDataSource.saveReferent(referent);

  @override
  Future<void> deleteReferent(String id) => localDataSource.deleteReferent(id);

  @override
  Future<void> saveLocalMessage(MessageEntity message) => localDataSource.saveMessage(message);

  @override
  Future<void> saveRemoteMessage(MessageEntity message) => remoteMessageDataSource.saveMessageToRemote(message);

  @override
  Future<List<MessageEntity>> getMessageHistory() => localDataSource.getMessageHistory();

  @override
  Future<List<MessageEntity>> getRemoteMessageHistory() => remoteMessageDataSource.getMessagesFromRemote();

  @override
  Future<void> sendEmailToExternalService({required ReferentEntity referent, required String subject, required String body}) {
    return emailSenderDataSource.sendEmail(referent: referent, subject: subject, body: body);
  }

  @override
  Future<void> saveRemoteReferent(ReferentEntity referent) =>
      remoteMessageDataSource.saveReferentToRemote(referent);

  @override
  Future<void> deleteRemoteReferent(String id) =>
      remoteMessageDataSource.deleteReferentFromRemote(id);

  @override
  Future<List<ReferentEntity>> getRemoteReferents() =>
      remoteMessageDataSource.getReferentsFromRemote();
}
