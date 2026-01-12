import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/enums/text_type.dart';
import '../../../../core/utils/connectivity_checker.dart';
import '../datasources/mlkit_ocr_datasource.dart';
import '../datasources/ocrspace_ocr_datasource.dart';

class OcrRepositoryImpl implements OcrRepository {
  final MLKitDataSource mlKitDataSource;
  final OCRSpaceDataSource ocrSpaceDataSource;

  OcrRepositoryImpl({
    required this.mlKitDataSource,
    required this.ocrSpaceDataSource,
  });

  @override
  Future<Either<Failure, OcrResult>> recognizeText({
    required File image,
    required TextType textType,
  }) async {
    try {
      if (textType == TextType.printed) {
        print('🔍 Utilisation de ML Kit (hors-ligne)');
        final result = await mlKitDataSource.recognizeText(image);
        return Right(result.toEntity());
      } else {
        print('🔍 Utilisation de OCR.space (en ligne)');

        final hasInternet = await ConnectivityChecker.hasInternetConnection();
        if (!hasInternet) {
          return const Left(
            NetworkFailure('Pas de connexion Internet.\nLe mode manuscrit nécessite une connexion.'),
          );
        }

        final result = await ocrSpaceDataSource.recognizeText(image);
        return Right(result.toEntity());
      }
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(OCRFailure('Erreur OCR: $e'));
    }
  }
}