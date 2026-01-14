import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/referent_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {

  final Box<ReferentEntity> _refBox = Hive.box<ReferentEntity>('referent_entity');
  final Box<MessageEntity> _historyBox = Hive.box<MessageEntity>('message_history');


  @override
  Future<List<ReferentEntity>> getReferents() async {
    // Si la box est vide au tout premier démarrage, on peut injecter des données initiales
    if (_refBox.isEmpty) {
      final List<ReferentEntity> initialData = [
         ReferentEntity(id: '1', name: 'Jean Dupont', email: 'laubert.yoann@gmail.com', role: 'Tuteur', category: 'Mon Référent'),
         ReferentEntity(id: '2', name: 'Alice Martin', email: 'a.martin@greta.fr', role: 'Conseillère', category: 'Mon Référent'),
         ReferentEntity(id: '3', name: 'Paul Bernard', email: 'p.bernard@capemploi.fr', role: 'Expert', category: 'CAP Emploi'),
         ReferentEntity(id: '4', name: 'Lucie Clerc', email: 'l.clerc@capemploi.fr', role: 'Chargée de mission', category: 'CAP Emploi'),
         ReferentEntity(id: '5', name: 'Marc Durand', email: 'm.durand@agefiph.fr', role: 'Délégué', category: 'AGEFIPH'),
         ReferentEntity(id: '6', name: 'Sophie Petit', email: 's.petit@agefiph.fr', role: 'Référente', category: 'AGEFIPH'),
      ];
      // On stocke directement l'objet
      for (var ref in initialData) {
        await _refBox.put(ref.id, ref);
      }
    }
    // Hive retourne déjà des ReferentEntity
    return _refBox.values.toList();
  }

  @override
  Future<void> addReferent(ReferentEntity referent) async {
    await _refBox.put(referent.id, referent);
  }

  @override
  Future<void> deleteReferent(String id) async {
    await _refBox.delete(id);
  }

  @override
  Future<void> sendEmailToReferent({
    required ReferentEntity referent,
    required String subject,
    required String body,
  }) async {
    const String apiKey = '';
    const String apiUrl = 'https://api.brevo.com/v3/smtp/email';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender': {'name': 'Leodys App', 'email': 'johngreta904@gmail.com'},
        'to': [{'email': referent.email, 'name': referent.name}],
        'subject': subject,
        'textContent': body,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur Brevo: ${response.body}');
    }
  }

  @override
  Future<void> saveMessage(MessageEntity message) async {
    // Stockage direct de l'objet MessageEntity
    await _historyBox.add(message);
  }


  @override
  Future<List<MessageEntity>> getMessageHistory() async {
    // Conversion simple et inversion pour avoir le plus récent en premier
    return _historyBox.values.toList().reversed.toList();
  }

}