import 'package:dartz/dartz.dart';
import 'package:leodys/common/domain/usecase.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/vocal_notes/domain/repositories/vocal_note_repository.dart';

/// Cas d'utilisation pour supprimer une note vocale.
class DeleteNoteUseCase implements UseCase<void, String> {
  final VocalNoteRepository repository;

  DeleteNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteNote(id);
  }
}
