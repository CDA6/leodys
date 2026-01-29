import 'package:flutter/material.dart';

import 'calculator_button.dart';

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
    '+': ['+', '+', '+', 'plus'],
    '-': ['-', '-', '-', 'moins'],
    '×': ['×', '×', '×', 'fois'],
    '÷': ['÷', '÷', '÷', 'divisé par'],
    '=': ['=', '=', '=', 'égal'],
    'C': ['C', 'C', 'C', 'tout effacer'],
    '⌫': ['⌫', '⌫', '⌫', 'effacer'],
    '☰': ['☰', '☰', '☰', 'historique'],
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
                  child: Semantics(
                    label: 'Bouton historique',
                    hint: 'Ouvrir l\'historique des calculs',
                    button: true,
                    enabled: true,
                    child: CalculatorButton(
                      text: _getDisplayText('☰'),
                      color: Colors.blueGrey,
                      textColor: Colors.white,
                      onPressed: () => widget.onHistoryPressed(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    label: 'Bouton tout effacer',
                    hint: 'Effacer tout le calcul en cours',
                    button: true,
                    enabled: true,
                    child: CalculatorButton(
                      text: _getDisplayText('C'),
                      color: Colors.orange,
                      textColor: Colors.white,
                      onPressed: widget.onClearPressed,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    label: 'Bouton effacer',
                    hint: 'Effacer le dernier caractère',
                    button: true,
                    enabled: true,
                    child: CalculatorButton(
                      text: _getDisplayText('⌫'),
                      color: Colors.orange,
                      textColor: Colors.white,
                      onPressed: widget.onBackspacePressed,
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    label: 'Bouton diviser',
                    hint: 'Diviser par',
                    button: true,
                    enabled: true,
                    child: CalculatorButton(
                      text: _getDisplayText('÷'),
                      color: Colors.blueGrey,
                      textColor: Colors.white,
                      onPressed: () => widget.onOperatorPressed('÷'),
                    ),
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
        // Bouton égal avec Semantics
        child = Semantics(
          label: 'Bouton égal',
          hint: 'Calculer le résultat',
          button: true,
          enabled: true,
          child: CalculatorButton(
            text: _getDisplayText(value),
            color: Colors.green,
            textColor: Colors.white,
            onPressed: widget.onEqualsPressed,
          ),
        );
      } else if (['+', '-', '×', '÷', '%'].contains(value)) {
        // Boutons opérateurs avec Semantics
        final operatorLabels = {
          '+': 'Bouton plus',
          '-': 'Bouton moins',
          '×': 'Bouton multiplier',
          '÷': 'Bouton diviser',
          '%': 'Bouton pourcentage',
        };
        child = Semantics(
          label: operatorLabels[value] ?? 'Bouton opérateur',
          hint: 'Opération ${_getDisplayText(value)}',
          button: true,
          enabled: true,
          child: CalculatorButton(
            text: _getDisplayText(value),
            color: Colors.blueGrey,
            textColor: Colors.white,
            onPressed: () => widget.onOperatorPressed(value),
          ),
        );
      } else if (value == 'MODE') {
        // Bouton pour changer le mode d'affichage avec Semantics dynamique
        final modeNames = ['points', 'dés', 'texte', 'chiffres'];
        final currentMode = modeNames[_displayMode];
        final nextMode = modeNames[(_displayMode + 1) % 4];
        child = Semantics(
          label: 'Bouton mode d\'affichage',
          hint: 'Mode actuel : $currentMode. Appuyer pour passer en mode $nextMode',
          button: true,
          enabled: true,
          child: CalculatorButton(
            text: 'Mode\n${['●','⚄ ⚄','Abc','123'][_displayMode]}',
            color: Colors.deepPurple,
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _displayMode = (_displayMode + 1) % 4;
              });
            },
          ),
        );
      } else if (value == '.') {
        // Bouton virgule avec Semantics
        child = Semantics(
          label: 'Bouton virgule',
          hint: 'Ajouter une virgule décimale',
          button: true,
          enabled: true,
          child: CalculatorButton(
            text: displayText,
            color: Colors.white30,
            textColor: Colors.white,
            onPressed: () => widget.onNumberPressed(value)
          ),
        );
      } else {
        // Boutons numériques avec Semantics
        final numberNames = {
          '0': 'zéro', '1': 'un', '2': 'deux', '3': 'trois',
          '4': 'quatre', '5': 'cinq', '6': 'six', '7': 'sept',
          '8': 'huit', '9': 'neuf'
        };
        child = Semantics(
          label: 'Bouton ${numberNames[value] ?? value}',
          hint: 'Entrer le chiffre ${numberNames[value] ?? value}',
          button: true,
          enabled: true,
          child: CalculatorButton(
            text: displayText,
            onPressed: () => widget.onNumberPressed(value),
          ),
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