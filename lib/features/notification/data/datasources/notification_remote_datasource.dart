import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../constants/mail_constants.dart';
import '../../domain/entities/referent_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<void> sendEmail({required ReferentEntity referent, required String subject, required String body});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  static final String _apiKey = MailConstants.apiKeyBrevo;
  static final String _apiUrl = MailConstants.apiUrlBrevo;
  static final String _sender = MailConstants.sender;


  @override
  Future<void> sendEmail({required ReferentEntity referent, required String subject, required String body}) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'api-key': _apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender': {'name': 'Leodys App', 'email': _sender},
        'to': [{'email': referent.email, 'name': referent.name}],
        'subject': subject,
        'textContent': body,
      }),
    );

    if (response.statusCode != 201) throw Exception('Erreur Brevo: ${response.body}');
  }
}