import '../../domain/entities/card_entity.dart';
import 'enums/card_suit_enum.dart';
import 'enums/card_value_enum.dart';

class CardModel {
  final String label;
  final double confidence;

  CardModel({
    required this.label,
    required this.confidence,
  });

  CardEntity toEntity() {
    return CardEntity(
      value: _translateValue(label),
      suit: _translateSuit(label),
      confidence: confidence,
    );
  }

  static CardValueEnum _translateValue(String label) {
    final cleaned = label.trim().toUpperCase();

    if (cleaned.startsWith('10')) {
      return CardValueEnum.TEN;
    }

    final valueChar = cleaned.substring(0, cleaned.length - 1);
    return CardValueEnum.fromAbbreviation(valueChar);
  }

  static CardSuitEnum _translateSuit(String label) {
    final cleaned = label.trim().toUpperCase();
    final suitChar = cleaned.substring(cleaned.length - 1);
    return CardSuitEnum.fromAbbreviation(suitChar);
  }
}