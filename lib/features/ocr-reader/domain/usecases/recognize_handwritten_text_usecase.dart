import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:leodys/core/utils/usecase.dart';
import '../entities/ocr_result.dart';
import '../repositories/ocr_repository.dart';
import '../../../../core/errors/failures.dart';

class RecognizeHandwrittenTextUseCase implements UseCase<OcrResult, File> {
  final OcrRepository repository;

  RecognizeHandwrittenTextUseCase(this.repository);

  @override
  Future<Either<Failure, OcrResult>> call(File image) async {
    return await repository.recognizeHandwrittenText(image);
  }
}