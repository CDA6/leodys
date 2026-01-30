import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../common/errors/failures.dart';
import '../entities/card_entity.dart';

abstract class CardDetectionRepository {
  Future<void> loadModel();
  Future<Either<Failure, List<CardEntity>>> detectCards(File imageFile);
  void dispose();
}