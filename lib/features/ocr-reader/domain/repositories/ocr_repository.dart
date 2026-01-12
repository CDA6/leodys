import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/ocr_result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/enums/text_type.dart';

abstract class OcrRepository {
  Future<Either<Failure, OcrResult>> recognizeText({
    required File image,
    required TextType textType,
  });
}