import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/ocr_result.dart';
import '../repositories/ocr_repository.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/enums/text_type.dart';

class RecognizeTextUseCase {
  final OcrRepository repository;

  RecognizeTextUseCase(this.repository);

  Future<Either<Failure, OcrResult>> call({
    required File image,
    required TextType textType,
  }) async {
    return await repository.recognizeText(
      image: image,
      textType: textType,
    );
  }
}