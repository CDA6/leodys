import 'dart:ui';

import 'package:flutter/material.dart';

/// Classe utilitaire pour les conversions et helpers de la calculatrice
class CalculatorHelpers {
  // Largeur fixe pour chaque bloc
  static const double blockWidth = 56.0; //56
  // Hauteur fixe pour chaque bloc
  static const double blockHeight = 80.0;
  // Nombre maximum de décimales affichées
  static const int maxDecimals = 5;

  /// Noms des places pour la partie entière (position depuis la droite)
  static String placeName(int posFromRight) {
    const names = [
      'unités',
      'dizaines',
      'centaines',
      'milliers',
      'diz. milliers',
      'c. milliers',
      'millions',
      'diz. millions',
      'c. millions',
      'milliards'
    ];
    if (posFromRight < names.length) return names[posFromRight];
    return '10^$posFromRight';
  }

  /// Noms des décimales
  static String decimalPlaceName(int decPos) {
    const names = ['dixième', 'centième', 'millième', '10^-4', '10^-5', '10^-6'];
    if (decPos - 1 < names.length) return names[decPos - 1];
    return '10^-$decPos';
  }

  /// Convertit UN SEUL nombre (sans opérateur) en texte français
  /// Usage interne uniquement - utiliser numberToWordsSegments() pour l'affichage
  static String _singleNumberToWords(String numberStr) {
    if (numberStr.isEmpty) return '';

    // Si nombre négatif
    bool neg = numberStr.startsWith('-');
    // on enlève le -
    String s = neg ? numberStr.substring(1) : numberStr;
    // Séparation partie entière et décimale
    List<String> parts = s.split('.');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? parts[1] : '';

    // gestion de la partie entière
    int? intValue = int.tryParse(intPart);
    String wordsInt;
    if (intValue == null) {
      wordsInt = intPart.split('').map((c) => _digitWord(c)).join(' ');
    } else {
      wordsInt = _intToFrench(intValue);
    }

    // gestion de la partie décimale
    if (decPart.isNotEmpty) {
      // Limite le nombre de décimales (pour eviter les incohérences entre affichage nombre et texte)
      if (decPart.length > CalculatorHelpers.maxDecimals) {
        decPart = decPart.substring(0, CalculatorHelpers.maxDecimals);
      }
      // Convertir la partie décimale comme un nombre entier
      int? decValue = int.tryParse(decPart);
      String decWords;

      if (decValue != null && decValue > 0) {
        // Lire comme un nombre entier (ex: "63" → "soixante-trois")
        decWords = _intToFrench(decValue);
      } else {
        // Si conversion impossible, lire chiffre par chiffre
        decWords = decPart.split('').map((c) => _digitWord(c)).join(' ');
      }

      return (neg ? 'moins ' : '') + wordsInt + ' virgule ' + decWords;
    }
    return (neg ? 'moins ' : '') + wordsInt;
  }

  /// Mot pour un chiffre unique
  static String _digitWord(String ch) {
    const map = {
      '0': 'zéro',
      '1': 'un',
      '2': 'deux',
      '3': 'trois',
      '4': 'quatre',
      '5': 'cinq',
      '6': 'six',
      '7': 'sept',
      '8': 'huit',
      '9': 'neuf',
      '-': 'moins',
      ',': 'virgule',
      '.': 'virgule',
      '×': 'fois',
      '÷': 'divisé par',
      '+': 'plus'
    };
    return map[ch] ?? ch;
  }

  /// Conversion d'un entier en français
  static String _intToFrench(int n) {
    if (n == 0) return 'zéro';
    if (n < 0) return 'moins ' + _intToFrench(-n);

    String result = '';
    int millions = n ~/ 1000000;
    int thousands = (n % 1000000) ~/ 1000;
    int rest = n % 1000;

    if (millions > 0) {
      result += (millions == 1
          ? 'un million'
          : '${_intToFrench(millions)} millions');
    }
    if (thousands > 0) {
      if (result.isNotEmpty) result += ' ';
      result += (thousands == 1
          ? 'mille'
          : '${_threeDigitsToFrench(thousands)} mille');
    }
    if (rest > 0) {
      if (result.isNotEmpty) result += ' ';
      result += _threeDigitsToFrench(rest);
    }
    return result;
  }

  /// Convertit 0..999 en français
  static String _threeDigitsToFrench(int n) {
    final units = [
      '',
      'un',
      'deux',
      'trois',
      'quatre',
      'cinq',
      'six',
      'sept',
      'huit',
      'neuf',
      'dix',
      'onze',
      'douze',
      'treize',
      'quatorze',
      'quinze',
      'seize'
    ];

    String underHundred(int m) {
      if (m < 17) return units[m];
      if (m < 20) return 'dix-${units[m - 10]}';
      if (m < 70) {
        int ten = (m ~/ 10) * 10;
        int u = m % 10;
        final tensMap = {
          20: 'vingt',
          30: 'trente',
          40: 'quarante',
          50: 'cinquante',
          60: 'soixante'
        };
        String tensWord = tensMap[ten] ?? ten.toString();
        if (u == 0) return tensWord;
        if (u == 1) return '$tensWord et un';
        return '$tensWord-${units[u]}';
      }
      if (m < 80) {
        return 'soixante-${underHundred(m - 60)}';
      }
      if (m == 80) return 'quatre-vingts';
      return 'quatre-vingt-${underHundred(m - 80)}';
    }

    int h = n ~/ 100;
    int rem = n % 100;
    String res = '';
    if (h > 0) {
      if (h == 1) {
        res = 'cent';
      } else {
        res = '${units[h]} cent';
      }
      if (rem == 0 && h > 1) res += 's';
    }
    if (rem > 0) {
      if (res.isNotEmpty) res += ' ';
      res += underHundred(rem);
    }
    return res;
  }

  /// Convertit le nombre en segments de couleur selon
  /// que l'on a un chiffre ou un mot-clé
  /// Tokenise l'expression complète (ex: "63+5") et traite chaque partie séparément
  static List<({String text, Color color})> numberToWordsSegments(String display) {
    final result = <({String text, Color color})>[];

    if (display == 'Erreur') {
      result.add((text: 'Erreur', color: Colors.red));
      return result;
    }

    if (display.isEmpty) {
      return result;
    }

    // Séparation des nombres et opérateurs (tokenisation)
    final List<String> tokens = [];
    int i = 0;
    while (i < display.length) {
      final ch = display[i];
      // Détection d'un opérateur, le - peut être le signe d'un nombre négatif
      if ((ch == '+' || ch == '×' || ch == '÷') ||
          (ch == '-' && i > 0 && RegExp(r'[0-9.]').hasMatch(display[i - 1]))) {
        tokens.add(ch);
        i++;
      } else {
        // sinon c'est un nombre
        int start = i;
        if (display[i] == '-') i++; // Signe négatif
        while (i < display.length && RegExp(r'[0-9.]').hasMatch(display[i])) {
          i++;
        }
        tokens.add(display.substring(start, i));
      }
    }

    // Converti chaque token en mots avec coloration
    for (final token in tokens) {
      if (['+', '-', '×', '÷'].contains(token)) {
        // Si opérateur con converti le mot en jaune
        final operatorWord = _digitWord(token);
        result.add((text: ' $operatorWord ', color: Colors.yellow));
      } else {
        // Si nombre convertion en mots
        final words = _singleNumberToWords(token).split(' ');
        for (final word in words) {
          if (word.isEmpty) continue;
          // Coloration selon le mot
          if (['million', 'millions', 'mille', 'cent', 'cents'].contains(word)) {
            result.add((text: '$word ', color: Colors.green));
          } else if (['virgule'].contains(word)) {
            result.add((text: '$word ', color: Colors.yellow));
          } else {
            result.add((text: '$word ', color: Colors.white70));
          }
        }
      }
    }
    return result;
  }
}