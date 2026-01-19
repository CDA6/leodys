import 'package:flutter_dotenv/flutter_dotenv.dart';

class MailConstants {
  static String get apiKeyBrevo => dotenv.env['BREVO_API_KEY'] ?? '';
  static const String apiUrlBrevo = 'https://api.brevo.com/v3/smtp/email';
  static const String sender = 'johngreta904@gmail.com';
}