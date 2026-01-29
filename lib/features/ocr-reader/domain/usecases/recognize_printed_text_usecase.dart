import 'dart:io';
import 'package:dartz/dartz.dart';

import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/ocr-reader/domain/entities/ocr_result.dart';
import 'package:leodys/features/ocr-reader/domain/repositories/ocr_repository.dart';

class RecognizePrintedTextUseCase with UseCaseMixin<OcrResult, File> {
  final OcrRepository repository;

  RecognizePrintedTextUseCase(this.repository);

  @override
  Future<Either<Failure, OcrResult>> execute(File image) async {
    return await repository.recognizePrintedText(image);
  }
}