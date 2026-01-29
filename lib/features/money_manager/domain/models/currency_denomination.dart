/// Représente une monnaie (billet ou pièce)
class CurrencyDenomination {
  final double value;
  final bool isBill;
  int count;
  int userGiven;

  CurrencyDenomination({
    required this.value,
    required this.isBill,
    this.count = 0,
    this.userGiven = 0,
  });

  /// Affichage de la valeur
  String get displayValue {
    if (value >= 1) {
      return '${value.toInt()}€';
    } else {
      return '${(value * 100).toInt()}c';
    }
  }

  String get type => isBill ? 'Billet' : 'Pièce';

  /// Chemin de l'image correspondant à cette dénomination
  String get imagePath {
    if (isBill) {
      // Billets : 5e.png, 10e.png, 20e.png, 50e.png, 100e.png, 200e.png, 500e.png
      return 'lib/features/money_manager/assets/images/bills/${value.toInt()}e.png';
    } else {
      // Pièces : pour les euros (1e.png, 2e.png) et centimes (1c.png, 2c.png, etc.)
      if (value >= 1) {
        return 'lib/features/money_manager/assets/images/coins/${value.toInt()}e.png';
      } else {
        return 'lib/features/money_manager/assets/images/coins/${(value * 100).toInt()}c.png';
      }
    }
  }

  CurrencyDenomination copyWith({
    double? value,
    bool? isBill,
    int? count,
    int? userGiven,
  }) {
    return CurrencyDenomination(
      value: value ?? this.value,
      isBill: isBill ?? this.isBill,
      count: count ?? this.count,
      userGiven: userGiven ?? this.userGiven,
    );
  }
}

/// Liste des billets et pièces disponibles en euros
List<CurrencyDenomination> getEuroDenominations() {
  return [
    // Billets
    CurrencyDenomination(value: 500, isBill: true),
    CurrencyDenomination(value: 200, isBill: true),
    CurrencyDenomination(value: 100, isBill: true),
    CurrencyDenomination(value: 50, isBill: true),
    CurrencyDenomination(value: 20, isBill: true),
    CurrencyDenomination(value: 10, isBill: true),
    CurrencyDenomination(value: 5, isBill: true),
    // Pièces
    CurrencyDenomination(value: 2, isBill: false),
    CurrencyDenomination(value: 1, isBill: false),
    CurrencyDenomination(value: 0.50, isBill: false),
    CurrencyDenomination(value: 0.20, isBill: false),
    CurrencyDenomination(value: 0.10, isBill: false),
    CurrencyDenomination(value: 0.05, isBill: false),
    CurrencyDenomination(value: 0.02, isBill: false),
    CurrencyDenomination(value: 0.01, isBill: false),
  ];
}