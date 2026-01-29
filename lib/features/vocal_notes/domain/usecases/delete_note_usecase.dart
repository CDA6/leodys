import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/vocal_notes/domain/repositories/vocal_note_repository.dart';

/// Cas d'utilisation pour supprimer une note vocale.
class DeleteNoteUseCase {
  final VocalNoteRepository repository;

  DeleteNoteUseCase(this.repository);

  Future<Either<Failure, void>> execute(String id) async {
    return await repository.deleteNote(id);
  }
}
