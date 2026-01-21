import '../models/reading_progress.dart';
import '../repositories/reading_progress_repository.dart';

class ReadingProgressUsecase {

  final ReadingProgressRepository readingProgressRepository;

  ReadingProgressUsecase(this.readingProgressRepository);

  /// Sauvegarde la progression de la lecture
  Future<void> saveProgress(ReadingProgress progress){
    return readingProgressRepository.saveProgress(progress);
  }

  /// Récupere la derniere progression sauvegarder
  Future<ReadingProgress?> getSaveProgress(){
    return readingProgressRepository.getSaveProgress();
  }

  /// Réinitiliser la progression de la lecture
  Future<void> resetProgress(){
    return readingProgressRepository.clearProgress();
  }
}