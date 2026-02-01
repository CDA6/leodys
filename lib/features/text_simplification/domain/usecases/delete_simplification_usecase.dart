import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/text_simplification/domain/repositories/text_simplification_repository.dart';

/// Cas d'utilisation pour supprimer une simplification (soft delete).
class DeleteSimplificationUseCase {
  final TextSimplificationRepository repository;

  DeleteSimplificationUseCase(this.repository);

  Future<Either<Failure, void>> execute(String id) async {
    return await repository.deleteSimplification(id);
  }
}
