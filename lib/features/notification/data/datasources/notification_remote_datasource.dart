import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../constants/mail_constants.dart';
import '../../domain/entities/referent_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<void> sendEmail({required ReferentEntity referent, required String subject, required String body});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  static final String _apiKey = MailConstants.apiKeyBrevo;
  static final String _apiUrl = MailConstants.apiUrlBrevo;
  static final String _sender = MailConstants.sender;
  final _supabase = Supabase.instance.client;


  @override
  Future<void> sendEmail({required ReferentEntity referent, required String subject, required String body}) async {
    try {
      // Appel de l'Edge Function au lieu d'un http.post direct
      final response = await _supabase.functions.invoke(
        'super-email-brevo',
        body: {
          'referentEmail': referent.email,
          'referentName': referent.name,
          'subject': subject,
          'body': body,
        },
      );

      if (response.status != 200 && response.status != 201) {
        throw Exception('Erreur Edge Function: ${response.data}');
      }
    } catch (e) {
      throw Exception('Erreur de communication avec le serveur: $e');
    }
  }
}