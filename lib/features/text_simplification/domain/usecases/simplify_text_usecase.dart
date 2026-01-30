import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/text_simplification/domain/repositories/text_simplification_repository.dart';

/// Cas d'utilisation pour simplifier un texte via le LLM.
class SimplifyTextUseCase {
  final TextSimplificationRepository repository;

  SimplifyTextUseCase(this.repository);

  Future<Either<Failure, String>> execute(String text) async {
    return await repository.simplifyText(text);
  }
}
