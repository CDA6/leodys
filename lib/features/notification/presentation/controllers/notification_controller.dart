import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/referent.dart';

class NotificationController {
  final NotificationRepository repository;
  NotificationController(this.repository);

  Future<List<Referent>> fetchReferents() => repository.getReferents();

  Future<void> notify(Referent referent) {
    return repository.sendEmailToReferent(
      referent: referent,
      subject: "Alerte de suivi Leodys",
      body: "Bonjour ${referent.name},\nJe souhaite vous contacter concernant...",
    );
  }
}