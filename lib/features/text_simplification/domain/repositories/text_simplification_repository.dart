import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/text_simplification/domain/entities/text_simplification_entity.dart';

abstract class TextSimplificationRepository {
  /// Envoie le texte au LLM pour simplification (adapté aux dyslexiques).
  Future<Either<Failure, String>> simplifyText(String text);

  /// Récupère toutes les simplifications (locales, puis sync background).
  Future<Either<Failure, List<TextSimplificationEntity>>> getAllSimplifications();

  /// Récupère une simplification par son ID.
  Future<Either<Failure, TextSimplificationEntity?>> getSimplificationById(String id);

  /// Sauvegarde une simplification (création ou modification).
  Future<Either<Failure, void>> saveSimplification(TextSimplificationEntity item);

  /// Supprime une simplification (soft delete).
  Future<Either<Failure, void>> deleteSimplification(String id);

  /// Force la synchronisation avec le serveur.
  Future<Either<Failure, void>> syncSimplifications();
}
