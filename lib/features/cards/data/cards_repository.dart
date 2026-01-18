import 'dart:io';
import 'package:leodys/features/cards/data/datasources/local/cards_local_datasource.dart';
import 'package:leodys/features/cards/data/datasources/remote/cards_remote_datasource.dart';

import '../domain/card_model.dart';

class CardsRepository {
  final CardsRemoteDatasource remote;
  final CardsLocalDatasource local;
  CardsRepository(this.remote, this.local);

  Future<List<CardModel>> getLocalUserCards() async {
    return await local.getLocalUserCards();
  }

  Future<void> uploadCard(CardModel card, String userId) async {
    await remote.uploadCard(userId, card);
  }

  Future<void> deleteCard(CardModel card) async {
    await local.removeCard(card);
  }

  Future<CardModel> saveNewCard(List<File> images, String cardName) async {
    return await local.saveScannedImages(images: images, cardName: cardName);
  }

  Future<void> markLocalCardAsDeleted(String cardId) async {
    await local.markAsDeleted(cardId);
  }

  Future<void> markLocalCardAsSynced(String cardId) async {
    await local.markAsSynced(cardId);
  }
}