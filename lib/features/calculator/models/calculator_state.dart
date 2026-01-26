/// Modèle représentant l'état complet de la calculatrice
/// Contient toutes les données nécessaires pour l'affichage et les calculs
/// Note: L'historique est géré séparément par HiveService
class CalculatorState {
  /// Texte actuellement affiché à l'écran
  final String display;

  /// Nombre en cours de saisie
  final String current;

  /// Expression en cours de construction (ex: "6+")
  final String expression;

  /// État d'erreur
  final bool hasError;

  /// Indique si on vient de calculer un résultat avec "="
  /// Permet de réutiliser le résultat avec un opérateur ou de le remplacer avec un chiffre
  final bool justCalculated;

  const CalculatorState({
    this.display = '0',
    this.current = '',
    this.expression = '',
    this.hasError = false,
    this.justCalculated = false, //boolean indiquant si on a deja un résultat
  });

  /// Crée une copie de l'état avec des modifications
  CalculatorState copyWith({
    String? display,
    String? current,
    String? expression,
    bool? hasError,
    bool? justCalculated,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      current: current ?? this.current,
      expression: expression ?? this.expression,
      hasError: hasError ?? this.hasError,
      justCalculated: justCalculated ?? this.justCalculated,
    );
  }

  /// État initial de la calculatrice
  static const initial = CalculatorState();
}