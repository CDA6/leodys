import '../models/reading_progress.dart';
import '../repositories/reading_progress_repository.dart';

class ReadingProgressUsecase {

  final ReadingProgressRepository readingProgressRepository;

  ReadingProgressUsecase(this.readingProgressRepository);


  /*
  Sauvegarde la progression de lecture
   */
  Future<void> saveProgress(ReadingProgress progress){
    return readingProgressRepository.saveProgress(progress);
  }

  /*
  Récupère la dernière progression sauvegardée
   */
  Future<ReadingProgress?> getSaveProgress(){
    return readingProgressRepository.getSaveProgress();
  }

  /*
  Réinitialiser la progression de la lecture
   */
  Future<void> resetProgress(){
    return readingProgressRepository.clearProgress();
  }
}