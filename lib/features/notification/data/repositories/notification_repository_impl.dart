import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/referent.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<Referent>> getReferents() async {
    // Simulation : À remplacer par un appel Supabase :
    // Supabase.instance.client.from('referents').select();
    return [
      const Referent(id: '1', name: 'Jean Dupont', email: 'jean.dupont@greta.fr', role: 'Tuteur'),
      const Referent(id: '2', name: 'Marie Curie', email: 'm.curie@greta.fr', role: 'Coordinatrice'),
    ];
  }

  @override
  Future<void> sendEmailToReferent({
    required Referent referent,
    required String subject,
    required String body,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: referent.email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw Exception('Impossible de lancer l\'application de messagerie');
    }
  }
}