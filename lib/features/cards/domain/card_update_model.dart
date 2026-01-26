import 'dart:io';

import 'card_model.dart';

class CardUpdateModel {
  final CardModel card;
  final String? newName;
  final File? newRecto;
  final File? newVerso;
  final bool removeVerso;

  CardUpdateModel({
    required this.card,
    this.newName,
    this.newRecto,
    this.newVerso,
    this.removeVerso = false,
  });

  @override
  String toString() {
    return 'CardUpdateModel{card: $card, newName: $newName, newRecto: $newRecto, newVerso: $newVerso, removeVerso: $removeVerso}';
  }
}