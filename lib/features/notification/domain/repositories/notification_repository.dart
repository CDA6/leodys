import '../entities/referent.dart';

abstract class NotificationRepository {
  Future<void> sendEmailToReferent({
    required Referent referent,
    required String subject,
    required String body,
  });

  Future<List<Referent>> getReferents();
}