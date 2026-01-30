import 'package:flutter/services.dart';

class NoAccentsInputFormatter extends TextInputFormatter {
  final RegExp _noAccentsRegex = RegExp(r'^[a-zA-Z0-9 \-_,.!?]+$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Vérifie si la nouvelle valeur contient des accents
    if (_noAccentsRegex.hasMatch(newValue.text)) {
      return newValue; // Accepte la nouvelle valeur
    } else {
      return oldValue; // Rejette la nouvelle valeur et garde l'ancienne
    }
  }
}
