import 'package:flutter_dotenv/flutter_dotenv.dart';

class BDDConstants {
  static String get apiKeyBDD => dotenv.env['SUPABASE_BDD_ANON_KEY'] ?? '';

}