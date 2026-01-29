import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/vocal_notes/domain/entities/vocal_note_entity.dart';
import 'package:leodys/features/vocal_notes/domain/repositories/vocal_note_repository.dart';

/// Paramètres pour le cas d'utilisation GetAllNotes.
/// Utilise [NoParams] car aucun paramètre n'est nécessaire.
class NoParams {}

/// Cas d'utilisation pour récupérer toutes les notes vocales.
class GetAllNotesUseCase {
  final VocalNoteRepository repository;

  GetAllNotesUseCase(this.repository);

  Future<Either<Failure, List<VocalNoteEntity>>> execute(NoParams params) async {
    return await repository.getAllNotes();
  }
}
