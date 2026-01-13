import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/referent_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final smtpServer = gmail("votre.email@gmail.com", "votre_mot_de_passe_app");
  final List<MessageEntity> _messageHistory = [];
  // Liste simulée en mémoire (à terme liée à Supabase via client.from('referents'))
  final List<Referent> _mockData = [
    const Referent(id: '1', name: 'Jean Dupont', email: 'j.dupont@greta.fr', role: 'Tuteur', category: 'Mon Référent'),
    const Referent(id: '2', name: 'Alice Martin', email: 'a.martin@greta.fr', role: 'Conseillère', category: 'Mon Référent'),
    const Referent(id: '3', name: 'Paul Bernard', email: 'p.bernard@capemploi.fr', role: 'Expert', category: 'CAP Emploi'),
    const Referent(id: '4', name: 'Lucie Clerc', email: 'l.clerc@capemploi.fr', role: 'Chargée de mission', category: 'CAP Emploi'),
    const Referent(id: '5', name: 'Marc Durand', email: 'm.durand@agefiph.fr', role: 'Délégué', category: 'AGEFIPH'),
    const Referent(id: '6', name: 'Sophie Petit', email: 's.petit@agefiph.fr', role: 'Référente', category: 'AGEFIPH'),
  ];

  @override
  Future<List<Referent>> getReferents() async => _mockData;

  @override
  Future<void> addReferent(Referent referent) async {
    _mockData.add(referent);
  }

  @override
  Future<void> deleteReferent(String id) async {
    _mockData.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> sendEmailToReferent({
    required Referent referent,
    required String subject,
    required String body,
  }) async {
    final message = Message()
      ..from = Address("votre.email@gmail.com", 'Application Leodys')
      ..recipients.add(referent.email)
      ..subject = subject
      ..text = body;

    try {
      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Échec de l\'envoi direct : $e');
    }
  }

  @override
  Future<List<MessageEntity>> getMessageHistory() async {
    return _messageHistory.reversed.toList(); // Plus récent en premier
  }

  @override
  Future<void> saveMessage(MessageEntity message) async {
    _messageHistory.add(message);
  }

}