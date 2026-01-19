import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/vocal_notes/domain/entities/vocal_note_entity.dart';

abstract class VocalNoteRepository {
  /// Récupère toutes les notes (locales, puis sync background).
  Future<Either<Failure, List<VocalNoteEntity>>> getAllNotes();

  /// Récupère une note par son ID.
  Future<Either<Failure, VocalNoteEntity?>> getNoteById(String id);

  /// Sauvegarde une note (création ou modification).
  Future<Either<Failure, void>> saveNote(VocalNoteEntity note);

  /// Supprime une note (soft delete).
  Future<Either<Failure, void>> deleteNote(String id);

  /// Force la synchronisation avec le serveur.
  Future<Either<Failure, void>> syncNotes();
}
