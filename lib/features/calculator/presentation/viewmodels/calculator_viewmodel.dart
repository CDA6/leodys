import 'package:flutter/material.dart';
import '../../domain/entity/calculator_state_model.dart';
import '../../presentation/views/calculator_history_view.dart';
import '../../data/repositories/hive_service.dart';

/// ViewModel de la calculatrice - Gère toute la logique métier
class CalculatorViewModel extends ChangeNotifier {
  static const String route = '/calculator';
  // État courant de la calculatrice
  CalculatorState _state = CalculatorState.initial;

  // Service Hive pour l'historique
  final _historyService = HiveService();

  // Getter pour l'état
  CalculatorState get state => _state;

  /// Met à jour l'état et notifie les listeners
  void _updateState(CalculatorState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Gère l'appui sur un chiffre ou le point
  void onNumberPressed(String value) {
    // Si on vient de calculer un résultat, recommencer à zéro avec ce chiffre
    if (_state.justCalculated) {
      String newCurrent = value;
      _updateState(_state.copyWith(
        current: newCurrent,
        display: newCurrent,
        expression: '',
        justCalculated: false,
      ));
      return;
    }

    // On ne peut pas mettre 2 points
    if (value == '.' && _state.current.contains('.')) return;

    // Gestion des cas speciaux (0 ou . en premier)
    String newCurrent = (_state.current == '0' && value != '.')
        ? value
        : _state.current + value;
    if (newCurrent.isEmpty) newCurrent = '0';

    // Expression a afficher
    String newDisplay = _state.expression.isNotEmpty
        ? '${_state.expression}$newCurrent'
        : newCurrent;

    // Mise a jour de l'affichage
    _updateState(_state.copyWith(
      current: newCurrent,
      display: newDisplay,
    ));
  }

  /// Gère l'appui sur un opérateur (+, -, ×, ÷)
  void onOperatorPressed(String op) {
    // Si on vient de calculer, réutiliser le résultat
    if (_state.justCalculated) {
      _updateState(_state.copyWith(
        expression: '${_state.display}$op',
        current: '',
        display: '${_state.display}$op',
        justCalculated: false,
      ));
      return;
    }

    // Cas spécial: démarrer un nombre négatif
    if (_state.current.isEmpty && _state.expression.isEmpty) {
      if (op == '-' && _state.current.isEmpty) {
        _updateState(_state.copyWith(
          current: '-',
          display: '-',
        ));
      }
      return;
    }

    String newExpression = _state.expression;

    // Ajouter la saisie à l'expression
    if (_state.current.isNotEmpty) {
      newExpression += _state.current;
    }

    // Remplacer l'opérateur si l'expression se termine déjà par un opérateur
    if (newExpression.isNotEmpty &&
        ['+', '-', '×', '÷'].contains(newExpression[newExpression.length - 1])) {
      newExpression = newExpression.substring(0, newExpression.length - 1) + op;
    } else {
      newExpression += op;
    }

    // Mise a jour de l'affichage
    _updateState(_state.copyWith(
      expression: newExpression,
      current: '',
      display: newExpression,
    ));
  }

  /// Gère l'appui sur le bouton d'historique
  void onHistoryPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return HistoryDialog(viewModel: this);
      },
    );
  }

  /// Récupère l'historique depuis HiveService
  List<String> getHistory() {
    return _historyService.getEntries();
  }

  /// Gere l'appui sur le bouton =
  /// Calcule et affiche le résultat
  void onEqualsPressed() {
    String fullExpr = _state.expression + _state.current;
    if (fullExpr.isEmpty) return;

    // Ne pas calculer si l'expression se termine par un opérateur
    if (['+', '-', '×', '÷'].contains(fullExpr[fullExpr.length - 1])) return;

    // Évaluer l'expression
    final result = _evaluateExpression(fullExpr);

    // Ajouter à l'historique dans Hive
    _historyService.saveEntry('$fullExpr = ${_formatResult(result)}');

    // Mise a jour de l'affichage
    _updateState(_state.copyWith(
      display: result.isNaN ? 'Erreur' : _formatResult(result),
      current: '',
      expression: '',
      hasError: result.isNaN,
      justCalculated: true, // Mémoriser qu'on vient de calculer
    ));
  }

  /// Réinitialise la calculatrice
  void onClearPressed() {
    _updateState(_state.copyWith(
      display: '0',
      current: '',
      expression: '',
      hasError: false,
      justCalculated: false,
    ));
  }

  /// Supprime le dernier caractère (backspace)
  void onBackspacePressed() {
    // Si il y'a un nombre
    if (_state.current.isNotEmpty) {
      String newCurrent = _state.current.substring(0, _state.current.length - 1); //On enleve le dernier chiffre
      String newDisplay;
      if (newCurrent.isEmpty) { // Si vide on affiche 0
        newDisplay = _state.expression.isNotEmpty ? _state.expression : '0';
      } else { // Sinon le nouveau nombre
        newDisplay = _state.expression.isNotEmpty
            ? '${_state.expression}$newCurrent'
            : newCurrent;
      }

      // Mise a jour de l'affichage
      _updateState(_state.copyWith(
        current: newCurrent,
        display: newDisplay,
      ));
    } else if (_state.expression.isNotEmpty) { //Si le calcul contient operateur ou point
      String newExpression =
          _state.expression.substring(0, _state.expression.length - 1); // On enleve le dernier caractere
      //Mise a jour de l'affichage
      _updateState(_state.copyWith(
        expression: newExpression,
        display: newExpression.isNotEmpty ? newExpression : '0',
      ));
    }
  }

  /// Évalue une expression arithmétique
  /// et règles de priorité (× et ÷)
  double _evaluateExpression(String expr) {
    try {
      // Extraire tous les nombres et opérateurs
      List<double> numbers = [];
      List<String> operators = [];
      StringBuffer currentNumber = StringBuffer();

      for (int i = 0; i < expr.length; i++) {
        String char = expr[i];

        if (char == '+' || char == '-' || char == '×' || char == '÷') {
          // Gérer le cas du nombre négatif au début
          if (char == '-' && currentNumber.isEmpty && numbers.isEmpty) {
            currentNumber.write(char);
            continue; // Ignore le reste de la boucle for cette itération
          }

          //Récupère le nombre courant
          if (currentNumber.isNotEmpty) {
            numbers.add(double.parse(currentNumber.toString().replaceAll(',', '.')));
            currentNumber.clear();
          }
          operators.add(char);
        } else {
          currentNumber.write(char);
        }
      }

      // Ajouter le dernier nombre
      if (currentNumber.isNotEmpty) {
        numbers.add(double.parse(currentNumber.toString().replaceAll(',', '.')));
      }

      if (numbers.isEmpty) return double.nan;

      // Étape 1 : Traiter × et ÷
      int i = 0;
      while (i < operators.length) {
        if (operators[i] == '×' || operators[i] == '÷') {
          double result;
          if (operators[i] == '×') {
            result = numbers[i] * numbers[i + 1];
          } else {
            // Division par zéro
            if (numbers[i + 1] == 0) return double.nan;
            result = numbers[i] / numbers[i + 1];
          }

          numbers[i] = result;
          numbers.removeAt(i + 1);
          operators.removeAt(i);
        } else {
          i++;
        }
      }

      // Étape 2 : Traiter + et -
      double result = numbers[0];
      for (int i = 0; i < operators.length; i++) {
        if (operators[i] == '+') {
          result += numbers[i + 1];
        } else if (operators[i] == '-') {
          result -= numbers[i + 1];
        }
      }

      return result;
    } catch (e) {
      return double.nan;
    }
  }

  /// Formate le résultat (enlève les décimales si entier)
  String _formatResult(double v) {
    if (v.isNaN) return 'Erreur';
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v.toString();
  }

  /// Efface l'historique des calculs
  void clearHistory() {
    _historyService.clearHistory();
  }
}