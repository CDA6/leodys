import 'package:leodys/src/features/audio_reader/domain/models/reading_progress.dart';

/*
Gestion des la progression de la lecture
 */
abstract class ReadingProgressRepository {

  /*
  Sauvegarde la progression de la lecture courante
   */
  Future<void> saveProgress(ReadingProgress progress);

  /*
  Récupère la lecture courante sauvegardé
  Retourne nulle "?" si pas de lecture
   */
  Future<ReadingProgress?> getSaveProgress();

  /*
  Supprimer la progression
   */
  Future<void> clearProgress();
}