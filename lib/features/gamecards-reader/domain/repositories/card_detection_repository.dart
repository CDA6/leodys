import 'dart:io';
import '../entities/card_entity.dart';

abstract class CardDetectionRepository {
  Future<void> loadModel();
  Future<List<CardEntity>> detectCards(File imageFile);
  void dispose();
}