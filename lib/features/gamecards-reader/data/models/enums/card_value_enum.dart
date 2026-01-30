enum CardValueEnum {
  ACE(fr: 'As', en: 'A'),
  TWO(fr: '2', en: '2'),
  THREE(fr: '3', en: '3'),
  FOUR(fr: '4', en: '4'),
  FIVE(fr: '5', en: '5'),
  SIX(fr: '6', en: '6'),
  SEVEN(fr: '7', en: '7'),
  EIGHT(fr: '8', en: '8'),
  NINE(fr: '9', en: '9'),
  TEN(fr: '10', en: '10'),
  JACK(fr: 'Valet', en: 'J'),
  QUEEN(fr: 'Dame', en: 'Q'),
  KING(fr: 'Roi', en: 'K');

  final String fr;
  final String en;

  const CardValueEnum({
    required this.fr,
    required this.en,
  });

  static CardValueEnum fromAbbreviation(String abbr) {
    switch (abbr.toUpperCase()) {
      case 'A': return CardValueEnum.ACE;
      case '2': return CardValueEnum.TWO;
      case '3': return CardValueEnum.THREE;
      case '4': return CardValueEnum.FOUR;
      case '5': return CardValueEnum.FIVE;
      case '6': return CardValueEnum.SIX;
      case '7': return CardValueEnum.SEVEN;
      case '8': return CardValueEnum.EIGHT;
      case '9': return CardValueEnum.NINE;
      case '10': return CardValueEnum.TEN;
      case 'J': return CardValueEnum.JACK;
      case 'Q': return CardValueEnum.QUEEN;
      case 'K': return CardValueEnum.KING;
      default: throw ArgumentError('Valeur invalide : $abbr');
    }
  }
}