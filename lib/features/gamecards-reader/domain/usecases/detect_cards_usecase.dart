import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';

import '../entities/card_entity.dart';
import '../repositories/card_detection_repository.dart';

class DetectCardsUseCase with UseCaseMixin<List<CardEntity>, File>{
  final CardDetectionRepository repository;

  DetectCardsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<CardEntity>>> execute(File params) async {
    return await repository.detectCards(params);
  }
}