import 'package:flutter/material.dart';
import 'calculator_widgets.dart';

/// Widget du clavier de la calculatrice
/// Contient tous les boutons et délègue les actions aux callbacks
class CalculatorKeypad extends StatelessWidget {
  final void Function(String) onNumberPressed;
  final void Function(String) onOperatorPressed;
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Première ligne : clear, M, %, backspace
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CalculatorButton(
                    text: 'C',
                    color: Colors.orange,
                    textColor: Colors.white,
                    onPressed: onClearPressed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalculatorButton(
                    text: 'M',
                    color: Colors.orange,
                    textColor: Colors.white,
                    onPressed: () => onOperatorPressed('÷'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalculatorButton(
                    text: '%',
                    color: Colors.blueGrey,
                    textColor: Colors.white,
                    onPressed: () => onOperatorPressed('×'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalculatorButton(
                    text: '⌫',
                    onPressed: onBackspacePressed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lignes numériques
          Expanded(child: _buildNumRow(['7', '8', '9', '-'])),
          const SizedBox(height: 8),
          Expanded(child: _buildNumRow(['4', '5', '6', '+'])),
          const SizedBox(height: 8),
          Expanded(child: _buildNumRow(['1', '2', '3', '÷'])),
          const SizedBox(height: 8),

          // Dernière ligne : 0, ., =
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CalculatorButton(
                    text: '0',
                    onPressed: () => onNumberPressed('0'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalculatorButton(
                    text: '.',
                    onPressed: () => onNumberPressed('.'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CalculatorButton(
                    text: '=',
                    color: Colors.green,
                    textColor: Colors.white,
                    onPressed: onEqualsPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une ligne de boutons
  Widget _buildNumRow(List<String> items) {
    List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      final t = items[i];
      Widget child;
      if (t == '=') {
        child = CalculatorButton(
          text: t,
          color: Colors.green,
          textColor: Colors.white,
          onPressed: onEqualsPressed,
        );
      } else if (['+', '-', '×', '÷'].contains(t)) {
        child = CalculatorButton(
          text: t,
          color: Colors.blueGrey,
          textColor: Colors.white,
          onPressed: () => onOperatorPressed(t),
        );
      } else {
        child = CalculatorButton(
          text: t,
          onPressed: () => onNumberPressed(t),
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