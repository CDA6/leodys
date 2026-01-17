import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../common/errors/failures.dart';
import '../entities/ocr_result.dart';

abstract class OcrRepository {
  Future<Either<Failure, OcrResult>> recognizePrintedText(File image);
  Future<Either<Failure, OcrResult>> recognizeHandwrittenText(File image);
}