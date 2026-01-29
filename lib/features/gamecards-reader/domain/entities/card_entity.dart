import 'dart:ui';
import '../../data/models/enums/card_suit_enum.dart';
import '../../data/models/enums/card_value_enum.dart';


class CardEntity {
  final CardValueEnum value;
  final CardSuitEnum suit;
  final double confidence;

  CardEntity({
    required this.value,
    required this.suit,
    required this.confidence,
  });

  /// Nom court pour affichage compact
  String get name => '${value.fr} ${suit.fr}';

  /// Symbole de la carte (ex: "♥")
  String get symbol => suit.symbol;

  /// Couleur associée à la carte (ex: Colors.red pour Cœur)
  Color get color => suit.color;

  @override
  String toString() => 'CardEntity($name, ${(confidence * 100).toStringAsFixed(1)}%)';
}