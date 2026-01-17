import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../common/errors/failures.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../../../common/utils/connectivity_checker.dart';
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
  Future<Either<Failure, OcrResult>> recognizePrintedText(File image) async {
    try {
      print('🔍 Utilisation de ML Kit (hors-ligne)');
      final result = await mlKitDataSource.recognizeText(image);
      return Right(result.toEntity());
    } on Exception catch (e) {
      return Left(OCRFailure('Erreur ML Kit: $e'));
    } catch (e) {
      return Left(OCRFailure('Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, OcrResult>> recognizeHandwrittenText(File image) async {
    try {
      print('🔍 Utilisation de OCR.space (en ligne)');

      // Vérification de la connexion Internet
      final hasInternet = await ConnectivityChecker.hasInternetConnection();
      if (!hasInternet) {
        return const Left(
          NetworkFailure(
            'Pas de connexion Internet.\nLe mode manuscrit nécessite une connexion.',
          ),
        );
      }

      final result = await ocrSpaceDataSource.recognizeText(image);
      return Right(result.toEntity());
    } on NetworkFailure catch (e) {
      return Left(e);
    } on Exception catch (e) {
      return Left(OCRFailure('Erreur OCR.space: $e'));
    } catch (e) {
      return Left(OCRFailure('Erreur inattendue: $e'));
    }
  }
}