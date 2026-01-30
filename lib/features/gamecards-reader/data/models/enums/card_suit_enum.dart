import 'package:flutter/material.dart';

enum CardSuitEnum {
  HEART(symbol: '♥', fr: 'Cœur', color: Colors.red),
  DIAMOND(symbol: '♦', fr: 'Carreau', color: Colors.red),
  CLUB(symbol: '♣', fr: 'Trèfle', color: Colors.black),
  SPADE(symbol: '♠', fr: 'Pique', color: Colors.black);

  final String symbol;
  final String fr;
  final Color color;

  const CardSuitEnum({
    required this.symbol,
    required this.fr,
    required this.color,
  });

  static CardSuitEnum fromAbbreviation(String abbr) {
    switch (abbr.toUpperCase()) {
      case 'H': return CardSuitEnum.HEART;
      case 'D': return CardSuitEnum.DIAMOND;
      case 'C': return CardSuitEnum.CLUB;
      case 'S': return CardSuitEnum.SPADE;
      default: throw ArgumentError('Couleur invalide : $abbr');
    }
  }
}
