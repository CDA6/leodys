import 'package:flutter/material.dart';
import 'calculator_widgets.dart';

/// Widget du clavier de la calculatrice
/// Contient tous les boutons et délègue les actions aux callbacks
class CalculatorKeypad extends StatefulWidget {
  final void Function(String) onNumberPressed;
  final void Function(String) onOperatorPressed;
  final void Function() onHistoryPressed;
  final VoidCallback onEqualsPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onBackspacePressed;

  const CalculatorKeypad({
    Key? key,
    required this.onNumberPressed,
    required this.onOperatorPressed,
    required this.onEqualsPressed,
    required this.onClearPressed,
    required this.onBackspacePressed,
    required this.onHistoryPressed,
  }) : super(key: key);

  @override
  State<CalculatorKeypad> createState() => _CalculatorKeypadState();
}

class _CalculatorKeypadState extends State<CalculatorKeypad> {
  // Mode d'affichage : 0=chiffres, 1=points, 2=dés, 3=texte
  int _displayMode = 0;

  // Mapping des valeurs fonctionnelles vers les représentations visuelles
  final Map<String, List<String>> _displayVariants = {
    '0': ['0', '⚬', '⌀', 'zéro'], // '⌀'
    '1': ['1', '●', '⚀', 'un'], //'⚀'
    '2': ['2', '●●', '⚁', 'deux'], // '⚁'
    '3': ['3', '●●●', '⚂', 'trois'], // '⚂'
    '4': ['4', '●●●●', '⚃', 'quatre'], // '⚃'
    '5': ['5', '●●●●●', '⚄', 'cinq'], // '⚄'
    '6': ['6', '●●●●●\n●', '⚄⚀', 'six'],
    '7': ['7', '●●●●●\n●●', '⚄⚁', 'sept'],
    '8': ['8', '●●●●●\n●●●', '⚄⚂', 'huit'],
    '9': ['9', '●●●●●\n●●●●', '⚄⚃', 'neuf'],
    '.': ['.', '•', ',', 'virgule'],
  };

  /// Obtient le texte d'affichage selon le mode actuel
  String _getDisplayText(String value) {
    if (_displayVariants.containsKey(value)) {
      return _displayVariants[value]![_displayMode];
    }
    return value; // Retourne la valeur originale pour les opérateurs
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Première ligne : clear, backspace, historique, opérateur +
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CalculatorButton(
                    text: 'C',
                    color: Colors.orange,
                    textColor: Colors.white,
                    onPressed: widget.onClearPressed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalculatorButton(
                    text: '⌫',
                    color: Colors.orange,
                    textColor: Colors.white,
                    onPressed: widget.onBackspacePressed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalculatorButton(
                    text: '☰',
                    color: Colors.blueGrey,
                    textColor: Colors.white,
                    onPressed: () => widget.onHistoryPressed(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalculatorButton(
                    text: '÷',
                    color: Colors.blueGrey,
                    textColor: Colors.white,
                    onPressed: () => widget.onOperatorPressed('÷'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lignes numériques
          Expanded(child: _buildRow(['7', '8', '9', '×'])),
          const SizedBox(height: 8),
          Expanded(child: _buildRow(['4', '5', '6', '-'])),
          const SizedBox(height: 8),
          Expanded(child: _buildRow(['1', '2', '3', '+'])),
          const SizedBox(height: 8),
          Expanded(child: _buildRow(['MODE', '0', '.', '='])),
        ],
      ),
    );
  }

  /// Construit une ligne de boutons
  Widget _buildRow(List<String> items) {
    List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      final value = items[i];
      final displayText = _getDisplayText(value);

      Widget child;
      if (value == '=') {
        // Bouton égal
        child = CalculatorButton(
          text: displayText,
          color: Colors.green,
          textColor: Colors.white,
          onPressed: widget.onEqualsPressed,
        );
      } else if (['+', '-', '×', '÷', '%'].contains(value)) {
        // Boutons opérateurs
        child = CalculatorButton(
          text: displayText,
          color: Colors.blueGrey,
          textColor: Colors.white,
          onPressed: () => widget.onOperatorPressed(value),
        );
      } else if (value == 'MODE') {
        // Bouton pour changer le mode d'affichage
        child = CalculatorButton(
          text: ['123', '●●●', '⚀⚁⚂', 'ABC'][_displayMode],
          color: Colors.deepPurple,
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _displayMode = (_displayMode + 1) % 4;
            });
          },
        );
      } else if (value == '.') {
        child = CalculatorButton(
          text: displayText,
          color: Colors.white38,
          textColor: Colors.white,
          onPressed: () => widget.onNumberPressed(value)
        );
      } else {
        // Boutons numériques
        child = CalculatorButton(
          text: displayText,
          onPressed: () => widget.onNumberPressed(value),
        );
      }

      children.add(Expanded(child: child));
      if (i < items.length - 1) {
        children.add(const SizedBox(width: 8));
      }
    }
    return Row(children: children);
  }
}