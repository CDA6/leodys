import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/cards/data/datasources/local/cards_local_datasource.dart';
import 'package:leodys/features/cards/data/datasources/remote/cards_remote_datasource.dart';
import 'package:leodys/features/cards/domain/card_update_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/card_model.dart';

class CardsRepository {
  final CardsRemoteDatasource remote;
  final CardsLocalDatasource local;
  CardsRepository(this.remote, this.local);

  Future<Either<Failure, List<CardModel>>> getLocalUserCards() async {
    try {
      return Right(await local.getLocalUserCards());
    } on FileSystemException catch (e) {
      return Left(FileFailure(e.message)); // probleme gestionnaire de fichiers
    } on FormatException catch (e) {
      return Left(FormatFailure(e.message)); // json malformé par ex
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> uploadCard(CardModel card) async {
    try {
      await remote.uploadCard(card);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(PostgresFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }

    return const Right(unit);
  }

  Future<Either<Failure, void>> deleteCard(CardModel card) async {
    try {
      await local.removeCard(card);
    } on FileSystemException catch (e) {
      return Left(FileFailure(e.message)); // probleme gestionnaire de fichiers
    } on FormatException catch (e) {
      return Left(FormatFailure(e.message)); // json malformé par ex
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    return Right(unit);
  }

  Future<Either<Failure, CardModel>> saveNewCard(List<File> images, String cardName) async {
    try {
      final result = await local.saveScannedImages(images: images, cardName: cardName);
      return Right(result);
    } on FileSystemException catch (e) {
      return Left(FileFailure(e.message)); // probleme gestionnaire de fichiers
    } on FormatException catch (e) {
      return Left(FormatFailure(e.message)); // json malformé par ex
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> markLocalCardAsDeleted(String cardId) async {
    try {
      await local.markAsDeleted(cardId);
    } on FileSystemException catch (e) {
      return Left(FileFailure(e.message)); // probleme gestionnaire de fichiers
    } on FormatException catch (e) {
      return Left(FormatFailure(e.message)); // json malformé par ex
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    return Right(unit);
  }

  Future<Either<Failure, void>> markLocalCardAsSynced(String cardId) async {
    try {
      await local.markAsSynced(cardId);
    } on FileSystemException catch (e) {
      return Left(FileFailure(e.message)); // probleme gestionnaire de fichiers
    } on FormatException catch (e) {
      return Left(FormatFailure(e.message)); // json malformé par ex
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    return Right(unit);
  }

  Future<Either<Failure, CardModel>> updateCard(CardUpdateModel update) async {
    try {
      final card = await local.updateCard(update); // datasource locale
      return Right(card);
    } on FileSystemException catch (e) {
      return Left(FileFailure(e.message)); // probleme gestionnaire de fichiers
    } on FormatException catch (e) {
      return Left(FormatFailure(e.message)); // json malformé par ex
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> syncCards(String userId) async {
    try {
      final localCards = await local.getCardsToSync();

      for (final card in localCards) {
        if (card.deleted) {
          await remote.deleteCard(card.id, userId);
          await local.removeCard(card);
        } else {
          await remote.uploadCard(card);
          await local.markAsSynced(card.id);
        }
      }

      await remote.pullRemoteCards(userId);
      return const Right(unit);
    } on StorageException catch (e) {
      if (e.message.contains('Object not found')) {
        return const Right(unit); // état normal
      }
      return Left(StorageFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(PostgresFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }


}