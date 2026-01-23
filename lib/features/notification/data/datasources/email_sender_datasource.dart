import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/referent_entity.dart';

/// Abstraction pour l'envoi d'e-mails via un service externe.
abstract class EmailSenderDataSource {
  Future<void> sendEmail({required ReferentEntity referent, required String subject, required String body});
}

/// Implémentation concrète pour l'envoi d'e-mails via Supabase Edge Function.
class EmailSenderDataSourceImpl implements EmailSenderDataSource {
  final _supabase = Supabase.instance.client;

  @override
  Future<void> sendEmail({required ReferentEntity referent, required String subject, required String body}) async {
    try {
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