import 'package:flutter/material.dart';

/// Widget pour afficher un opérateur
class OperatorBlock extends StatelessWidget {
  final String operator;
  final double blockWidth;
  final double blockHeight;

  const OperatorBlock({
    super.key,
    required this.operator,
    required this.blockWidth,
    required this.blockHeight,
  });

  /// Retourne le nom en français de l'opérateur
  String _getOperatorName(String op) {
    const operatorNames = {
      '+': 'plus',
      '-': 'moins',
      '×': 'multiplier',
      '÷': 'diviser'
    };
    return operatorNames[op] ?? 'opérateur';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: blockWidth,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              operator,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: blockWidth - 12,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _getOperatorName(operator),
                maxLines: 1,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}