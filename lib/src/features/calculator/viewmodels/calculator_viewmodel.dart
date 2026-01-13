import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/calculator_state.dart';
import '../views/calculator_history.dart';

/// ViewModel de la calculatrice - Gère toute la logique métier
/// Utilise ChangeNotifier pour notifier les vues des changements d'état
class CalculatorViewModel extends ChangeNotifier {
  /// État courant de la calculatrice
  CalculatorState _state = CalculatorState.initial;

  /// Limite du nombre d'entrées dans l'historique
  static const int _historyLimit = 1000;

  /// Getter pour l'état
  CalculatorState get state => _state;

  /// Met à jour l'état et notifie les listeners
  void _updateState(CalculatorState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Gère l'appui sur un chiffre ou le point décimal
  void onNumberPressed(String value) {
    if (value == '.' && _state.current.contains('.')) return;

    String newCurrent = (_state.current == '0' && value != '.')
        ? value
        : _state.current + value;
    if (newCurrent.isEmpty) newCurrent = '0';

    String newDisplay = _state.expression.isNotEmpty
        ? '${_state.expression}$newCurrent'
        : newCurrent;

    _updateState(_state.copyWith(
      current: newCurrent,
      display: newDisplay,
    ));
  }

  /// Gère l'appui sur un opérateur (+, -, ×, ÷)
  void onOperatorPressed(String op) {
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

    // Ajouter la saisie courante à l'expression
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

  /// Calcule et affiche le résultat
  void onEqualsPressed() {
    String fullExpr = _state.expression + _state.current;
    if (fullExpr.isEmpty) return;

    // Ne pas évaluer si l'expression se termine par un opérateur
    if (['+', '-', '×', '÷'].contains(fullExpr[fullExpr.length - 1])) return;

    // Évaluer l'expression
    final result = _evaluateExpression(fullExpr);

    // Ajouter à l'historique
    List<String> newHistory = List.from(_state.history);
    // Ajouter le résultat à l'historique
    newHistory.add('$fullExpr = ${_formatResult(result)}');
    if (newHistory.length > _historyLimit) {
      newHistory.removeLast(); // .removeAt(0);
    }

    // Mettre à jour l'état
    _updateState(_state.copyWith(
      display: result.isNaN ? 'Erreur' : _formatResult(result),
      current: '',
      expression: '',
      history: newHistory,
      hasError: result.isNaN,
    ));
  }

  /// Réinitialise la calculatrice (conserve l'historique)
  void onClearPressed() {
    _updateState(_state.copyWith(
      display: '0',
      current: '',
      expression: '',
      hasError: false,
    ));
  }

  /// Supprime le dernier caractère (backspace)
  void onBackspacePressed() {
    if (_state.current.isNotEmpty) {
      String newCurrent = _state.current.substring(0, _state.current.length - 1);
      String newDisplay;
      if (newCurrent.isEmpty) {
        newDisplay = _state.expression.isNotEmpty ? _state.expression : '0';
      } else {
        newDisplay = _state.expression.isNotEmpty
            ? '${_state.expression}$newCurrent'
            : newCurrent;
      }

      _updateState(_state.copyWith(
        current: newCurrent,
        display: newDisplay,
      ));
    } else if (_state.expression.isNotEmpty) {
      String newExpression =
          _state.expression.substring(0, _state.expression.length - 1);
      _updateState(_state.copyWith(
        expression: newExpression,
        display: newExpression.isNotEmpty ? newExpression : '0',
      ));
    }
  }

  /// Évalue une expression arithmétique (gauche-à-droite)
  double _evaluateExpression(String expr) {
    try {
      // Tokenisation: nombres et opérateurs
      final tokens = <String>[];
      int i = 0;
      while (i < expr.length) {
        final c = expr[i];
        if (c == '+' ||
            c == '×' ||
            c == '÷' ||
            (c == '-' && i > 0 && RegExp(r'[0-9.]').hasMatch(expr[i - 1]))) {
          tokens.add(c);
          i++;
        } else {
          int start = i;
          if (expr[i] == '-') i++;
          while (i < expr.length && (RegExp(r'[0-9.]').hasMatch(expr[i]))) i++;
          tokens.add(expr.substring(start, i));
        }
      }

      // Évaluation gauche-à-droite
      if (tokens.isEmpty) return double.nan;
      double acc = double.parse(tokens[0].replaceAll(',', '.'));
      int idx = 1;
      while (idx < tokens.length) {
        final op = tokens[idx];
        final next = double.parse(tokens[idx + 1].replaceAll(',', '.'));
        switch (op) {
          case '+':
            acc = acc + next;
            break;
          case '-':
            acc = acc - next;
            break;
          case '×':
            acc = acc * next;
            break;
          case '÷':
            if (next == 0) return double.nan;
            acc = acc / next;
            break;
          default:
            return double.nan;
        }
        idx += 2;
      }
      return acc;
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
}