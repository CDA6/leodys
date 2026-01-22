import '../../domain/entities/message_entity.dart';
import '../../domain/entities/referent_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<ReferentEntity>> getReferents() => localDataSource.getReferents();

  @override
  Future<void> addReferent(ReferentEntity referent) => localDataSource.saveReferent(referent);

  @override
  Future<void> deleteReferent(String id) => localDataSource.deleteReferent(id);

  @override
  Future<void> saveMessage(MessageEntity message) => localDataSource.saveMessage(message);

  @override
  Future<List<MessageEntity>> getMessageHistory() => localDataSource.getMessageHistory();

  @override
  Future<void> sendEmailToReferent({required ReferentEntity referent, required String subject, required String body}) {
    return remoteDataSource.sendEmail(referent: referent, subject: subject, body: body);
  }
}