import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/repository_mixin.dart';
import 'package:leodys/common/utils/internet_util.dart';
import 'package:leodys/features/text_simplification/data/datasources/text_simplification_local_datasource.dart';
import 'package:leodys/features/text_simplification/data/datasources/text_simplification_remote_datasource.dart';
import 'package:leodys/features/text_simplification/data/models/text_simplification_model.dart';
import 'package:leodys/features/text_simplification/domain/entities/text_simplification_entity.dart';
import 'package:leodys/features/text_simplification/domain/repositories/text_simplification_repository.dart';
import 'package:leodys/features/vocal_chat/data/services/openrouter_service.dart';
import 'package:leodys/features/vocal_chat/domain/errors/failures.dart';

class TextSimplificationRepositoryImpl
    with RepositoryMixin
    implements TextSimplificationRepository {
  final OpenRouterService openRouterService;
  final TextSimplificationLocalDataSource localDataSource;
  final TextSimplificationRemoteDataSource remoteDataSource;

  /// Prompt systeme pour la simplification de texte pour dyslexiques.
  static const String _systemPrompt = '''Tu es un assistant specialise dans l'adaptation de textes pour les personnes dyslexiques.
Reecris le texte suivant en francais simplifie:
- Utilise des phrases courtes et simples
- Evite les mots complexes, prefere des synonymes plus simples
- Structure le texte avec des paragraphes courts
- Evite les doubles negations
- Utilise des mots concrets plutot qu'abstraits
- Garde le sens original du texte

Reponds uniquement avec le texte simplifie, sans explication.''';

  TextSimplificationRepositoryImpl({
    required this.openRouterService,
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // ============================================
  // LLM Simplification
  // ============================================

  @override
  Future<Either<Failure, String>> simplifyText(String text) async {
    return execute('simplifyText', () async {
      try {
        final messages = [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': text},
        ];

        final response = await openRouterService.sendChatCompletion(messages);
        return Right(response);
      } on OpenRouterFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(UnknownFailure('Erreur inattendue: $e'));
      }
    });
  }

  // ============================================
  // CRUD Operations with Sync
  // ============================================

  @override
  Future<Either<Failure, List<TextSimplificationEntity>>>
      getAllSimplifications() async {
    return execute('getAllSimplifications', () async {
      try {
        // 1. Charger depuis le local immediatement
        final localItems = await localDataSource.getAll();

        // 2. Tenter une synchro en arriere-plan si connecte (fire and forget)
        if (InternetUtil.isConnected) {
          _backgroundSync();
        }

        return Right(localItems);
      } catch (e) {
        return Left(NetworkFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, TextSimplificationEntity?>> getSimplificationById(
      String id) async {
    return execute('getSimplificationById', () async {
      try {
        final item = await localDataSource.getById(id);
        return Right(item);
      } catch (e) {
        return Left(NetworkFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, void>> saveSimplification(
      TextSimplificationEntity item) async {
    return execute('saveSimplification', () async {
      try {
        // Conversion Entity -> Model
        final model = TextSimplificationModel(
          id: item.id,
          originalText: item.originalText,
          simplifiedText: item.simplifiedText,
          createdAt: item.createdAt,
          updatedAt: DateTime.now().toUtc(),
          deletedAt: item.deletedAt,
        );

        // 1. Sauvegarder en local
        await localDataSource.save(model);

        // 2. Envoyer au serveur si connecte
        if (InternetUtil.isConnected) {
          try {
            await remoteDataSource.upsert(model);
          } catch (e) {
            // Echec silencieux, sera rattrape au prochain sync
          }
        }

        return const Right(null);
      } catch (e) {
        return Left(NetworkFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, void>> deleteSimplification(String id) async {
    return execute('deleteSimplification', () async {
      try {
        // 1. Supprimer en local (soft delete)
        await localDataSource.delete(id);

        // 2. Supprimer sur le serveur si connecte
        if (InternetUtil.isConnected) {
          try {
            await remoteDataSource.delete(id);
          } catch (e) {
            // Echec silencieux
          }
        }

        return const Right(null);
      } catch (e) {
        return Left(NetworkFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, void>> syncSimplifications() async {
    return execute('syncSimplifications', () async {
      if (!InternetUtil.isConnected) {
        return Left(NetworkFailure('Pas de connexion internet'));
      }

      try {
        await _executeSync();
        return const Right(null);
      } catch (e) {
        return Left(NetworkFailure(e.toString()));
      }
    });
  }

  // ============================================
  // Logique de Synchronisation
  // ============================================

  Future<void> _backgroundSync() async {
    try {
      await _executeSync();
    } catch (e) {
      // Log error silently
    }
  }

  Future<void> _executeSync() async {
    // 1. Pull : Recuperer tout depuis le serveur
    final remoteItems = await remoteDataSource.fetchAll();

    for (final remoteItem in remoteItems) {
      final localItem = await localDataSource.getById(remoteItem.id);

      if (localItem == null) {
        // Nouveau item du serveur
        await localDataSource.save(remoteItem);
      } else {
        // Conflit : Last Write Wins base sur updatedAt
        if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
          await localDataSource.save(remoteItem);
        } else if (localItem.updatedAt.isAfter(remoteItem.updatedAt)) {
          // Le local est plus recent, on push
          await remoteDataSource.upsert(localItem);
        }
      }
    }
  }
}
