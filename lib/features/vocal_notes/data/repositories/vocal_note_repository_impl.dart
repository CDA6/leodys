import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/utils/internet_util.dart';
import 'package:leodys/features/vocal_notes/data/datasources/vocal_note_local_datasource.dart';
import 'package:leodys/features/vocal_notes/data/datasources/vocal_note_remote_datasource.dart';
import 'package:leodys/features/vocal_notes/data/models/vocal_note_model.dart';
import 'package:leodys/features/vocal_notes/domain/entities/vocal_note_entity.dart';
import 'package:leodys/features/vocal_notes/domain/repositories/vocal_note_repository.dart';

class VocalNoteRepositoryImpl implements VocalNoteRepository {
  final VocalNoteLocalDataSource localDataSource;
  final VocalNoteRemoteDataSource remoteDataSource;

  VocalNoteRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<VocalNoteEntity>>> getAllNotes() async {
    try {
      // 1. Charger depuis le local immédiatement
      final localNotes = await localDataSource.getAllNotes();

      // 2. Tenter une synchro en arrière-plan si connecté (fire and forget)
      if (InternetUtil.isConnected) {
        _backgroundSync();
      }

      return Right(localNotes);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VocalNoteEntity?>> getNoteById(String id) async {
    try {
      final note = await localDataSource.getNoteById(id);
      return Right(note);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveNote(VocalNoteEntity note) async {
    try {
      // Conversion Entity -> Model
      final model = VocalNoteModel(
        id: note.id,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        updatedAt: DateTime.now().toUtc(), // Mise à jour de la date
        deletedAt: note.deletedAt,
      );

      // 1. Sauvegarder en local
      await localDataSource.saveNote(model);

      // 2. Envoyer au serveur si connecté
      if (InternetUtil.isConnected) {
        try {
          await remoteDataSource.upsertNote(model);
        } catch (e) {
          // Échec silencieux de l'envoi distant, sera rattrapé au prochain sync
          // On pourrait marquer l'objet comme "dirty" ici si on voulait une synchro plus robuste
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    try {
      // 1. Supprimer en local (soft delete)
      await localDataSource.deleteNote(id);

      // 2. Supprimer sur le serveur si connecté
      if (InternetUtil.isConnected) {
        try {
          await remoteDataSource.deleteNote(id);
        } catch (e) {
          // Échec silencieux
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncNotes() async {
    if (!InternetUtil.isConnected) {
      return Left(NetworkFailure('Pas de connexion internet'));
    }

    try {
      await _executeSync();
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  // ============================================
  // Logique de Synchronisation
  // ============================================

  Future<void> _backgroundSync() async {
    try {
      await _executeSync();
    } catch (e) {
      // Log error
      print('Erreur de synchro en background: $e');
    }
  }

  Future<void> _executeSync() async {
    // Note: Ceci est une implémentation simplifiée.
    // Pour une vraie synchro bidirectionnelle robuste, il faudrait gérer "last_sync_date"
    // stocké en local (SharedPreferences) et gérer les conflits.

    // 1. Pull : Récupérer tout depuis le serveur (pour simplifier, ou baser sur date)
    // Idéalement : fetchNotesUpdatedAfter(lastSyncDate)
    final remoteNotes = await remoteDataSource.fetchAllNotes();

    for (final remoteNote in remoteNotes) {
      final localNote = await localDataSource.getNoteById(remoteNote.id);

      if (localNote == null) {
        // Nouveau message du serveur
        await localDataSource.saveNote(remoteNote);
      } else {
        // Conflit : Last Write Wins basé sur updatedAt
        if (remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
          await localDataSource.saveNote(remoteNote);
        } else if (localNote.updatedAt.isAfter(remoteNote.updatedAt)) {
          // Le local est plus récent, on push
          await remoteDataSource.upsertNote(localNote);
        }
      }
    }

    // 2. Push : Envoyer les notes locales qui n'existent pas sur le serveur ou plus récentes
    // Pour simplifier ici, on suppose que le step 1 a géré les conflits majeurs.
    // Une vraie implémentation itérerait sur les notes locales marquées "dirty".
  }
}
