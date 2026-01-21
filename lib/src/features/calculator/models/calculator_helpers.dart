/// Classe utilitaire pour les conversions et helpers de la calculatrice
class CalculatorHelpers {
  /// Largeur fixe pour chaque bloc
  static const double blockWidth = 56.0;

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

  /// Convertit la chaîne d'affichage en texte français
  static String numberToWordsFromDisplay(String display) {
    if (display == 'Erreur') return 'Erreur';
    if (display.isEmpty) return '';

    bool neg = display.startsWith('-');
    String s = neg ? display.substring(1) : display;
    List<String> parts = s.split('.');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? parts[1] : '';

    int? intValue = int.tryParse(intPart);
    String wordsInt;
    if (intValue == null) {
      wordsInt = intPart.split('').map((c) => _digitWord(c)).join(' ');
    } else {
      wordsInt = _intToFrench(intValue);
    }

    if (decPart.isNotEmpty) {
      String decWords = decPart.split('').map((c) => _digitWord(c)).join(' ');
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
      '.': 'virgule'
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
}