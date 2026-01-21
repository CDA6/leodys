import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/vocal_notes/domain/entities/vocal_note_entity.dart';
import 'package:leodys/features/vocal_notes/domain/repositories/vocal_note_repository.dart';

/// Cas d'utilisation pour sauvegarder une note vocale.
class SaveNoteUseCase {
  final VocalNoteRepository repository;

  SaveNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VocalNoteEntity note) async {
    return await repository.saveNote(note);
  }
}
