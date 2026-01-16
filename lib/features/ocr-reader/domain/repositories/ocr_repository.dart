import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/ocr_result.dart';
import '../../../../core/errors/failures.dart';

abstract class OcrRepository {
  Future<Either<Failure, OcrResult>> recognizePrintedText(File image);
  Future<Either<Failure, OcrResult>> recognizeHandwrittenText(File image);
}