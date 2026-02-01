import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/text_simplification/domain/entities/text_simplification_entity.dart';
import 'package:leodys/features/text_simplification/domain/repositories/text_simplification_repository.dart';

/// Cas d'utilisation pour sauvegarder une simplification.
class SaveSimplificationUseCase {
  final TextSimplificationRepository repository;

  SaveSimplificationUseCase(this.repository);

  Future<Either<Failure, void>> execute(TextSimplificationEntity item) async {
    return await repository.saveSimplification(item);
  }
}
