import 'dart:io';
import 'package:dartz/dartz.dart';

import 'package:leodys/common/domain/usecase.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/ocr-reader/domain/entities/ocr_result.dart';
import 'package:leodys/features/ocr-reader/domain/repositories/ocr_repository.dart';

class RecognizeHandwrittenTextUseCase extends UseCase<OcrResult, File> {
  final OcrRepository repository;

  RecognizeHandwrittenTextUseCase(this.repository);

  @override
  Future<Either<Failure, OcrResult>> execute(File image) async {
    return await repository.recognizeHandwrittenText(image);
  }
}