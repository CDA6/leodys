import 'package:hive/hive.dart';
import 'package:leodys/src/features/audio_reader/domain/models/reading_progress.dart';
import 'package:leodys/src/features/audio_reader/domain/repositories/reading_progress_repository.dart';

/// Gestion de la sauvegarde locale de la progression de lecture avec Hive
class ReadingProgressRepositoryImpl implements ReadingProgressRepository {
  static const String _boxName = "reading_progress_box";
  static const String _progressKey = "reading_progress";

  /// Sauvegarde la progression de lecture
  @override
  Future<void> saveProgress(ReadingProgress progress) async {
    // Créer le conteneur box qui prendre en parametre la variable _boxName qui est nom du conteneur
    final box = await Hive.openBox(_boxName);

    // injecter dans la box clé: progressKey et les valeur de l'index de la page
    // et l'index du bloc de texte en cours
    await box.put(_progressKey, {
      'pageIndex': progress.pageIndex,
      'blocIndex': progress.blocIndex,
    });
  }

  /// Reprendre la lecture lors de la derniere progression
  @override
  Future<ReadingProgress?> getSaveProgress() async {
    final box = await Hive.openBox(_boxName);
    final data = box.get(_progressKey);

    if (data == null) {
      return null;
    }

    return ReadingProgress(
      pageIndex: data['pageIndex'],
      blocIndex: data['blocIndex'],
    );
  }

  /// Réinitialiser la lecture
  @override
  Future<void> clearProgress() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_progressKey);
  }
}
