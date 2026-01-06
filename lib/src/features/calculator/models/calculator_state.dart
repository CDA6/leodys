/// Modèle représentant l'état complet de la calculatrice
/// Contient toutes les données nécessaires pour l'affichage et les calculs
class CalculatorState {
  /// Texte actuellement affiché à l'écran
  final String display;

  /// Nombre en cours de saisie
  final String current;

  /// Expression en cours de construction (ex: "6+")
  final String expression;

  /// Historique des calculs effectués (anciennes entrées en haut, nouvelles en bas)
  final List<String> history;

  /// État d'erreur
  final bool hasError;

  const CalculatorState({
    this.display = '0',
    this.current = '',
    this.expression = '',
    this.history = const [],
    this.hasError = false,
  });

  /// Crée une copie de l'état avec des modifications
  CalculatorState copyWith({
    String? display,
    String? current,
    String? expression,
    List<String>? history,
    bool? hasError,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      current: current ?? this.current,
      expression: expression ?? this.expression,
      history: history ?? this.history,
      hasError: hasError ?? this.hasError,
    );
  }

  /// État initial de la calculatrice
  static const initial = CalculatorState();
}