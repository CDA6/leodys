import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:leodys/common/utils/internet_util.dart';
import 'package:leodys/common/domain/repository.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/ocr-reader/domain/entities/ocr_result.dart';
import 'package:leodys/features/ocr-reader/domain/repositories/ocr_repository.dart';
import 'package:leodys/features/ocr-reader/data/datasources/mlkit_ocr_datasource.dart';
import 'package:leodys/features/ocr-reader/data/datasources/ocrspace_ocr_datasource.dart';

class OcrRepositoryImpl with Repository implements OcrRepository {
  final MLKitDataSource mlKitDataSource;
  final OCRSpaceDataSource ocrSpaceDataSource;

  OcrRepositoryImpl({
    required this.mlKitDataSource,
    required this.ocrSpaceDataSource,
  });

  @override
  Future<Either<Failure, OcrResult>> recognizePrintedText(File image) async {
    return execute('recognizePrintedText', () async {
      try {
        final result = await mlKitDataSource.recognizeText(image);
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(OCRFailure('Erreur ML Kit: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, OcrResult>> recognizeHandwrittenText(File image) async {
    return execute('recognizeHandwrittenText', () async {
      try {
        final hasInternet = InternetUtil.isConnected;
        if (!hasInternet) {
          return const Left(
            NetworkFailure('Pas de connexion Internet.\nLe mode manuscrit nécessite une connexion.'),
          );
        }

        final result = await ocrSpaceDataSource.recognizeText(image);
        return Right(result.toEntity());
      } on NetworkFailure catch (e) {
        return Left(e);
      } on Exception catch (e) {
        return Left(OCRFailure('Erreur OCR.space: $e'));
      }
    });
  }
}