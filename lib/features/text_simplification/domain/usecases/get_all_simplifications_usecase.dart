import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/text_simplification/domain/entities/text_simplification_entity.dart';
import 'package:leodys/features/text_simplification/domain/repositories/text_simplification_repository.dart';

/// Cas d'utilisation pour récupérer l'historique des simplifications.
class GetAllSimplificationsUseCase {
  final TextSimplificationRepository repository;

  GetAllSimplificationsUseCase(this.repository);

  Future<Either<Failure, List<TextSimplificationEntity>>> execute() async {
    return await repository.getAllSimplifications();
  }
}
