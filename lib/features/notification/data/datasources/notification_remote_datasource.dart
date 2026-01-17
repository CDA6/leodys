import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/referent_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<void> sendEmail({required ReferentEntity referent, required String subject, required String body});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  static const String _apiKey = 'TA_CLE_BREVO';
  static const String _apiUrl = 'https://api.brevo.com/v3/smtp/email';

  @override
  Future<void> sendEmail({required ReferentEntity referent, required String subject, required String body}) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'api-key': _apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender': {'name': 'Leodys App', 'email': 'johngreta904@gmail.com'},
        'to': [{'email': referent.email, 'name': referent.name}],
        'subject': subject,
        'textContent': body,
      }),
    );

    if (response.statusCode != 201) throw Exception('Erreur Brevo: ${response.body}');
  }
}