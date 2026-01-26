import 'package:flutter/cupertino.dart';
import '../../domain/models/reading_progress.dart';
import '../../domain/usecases/reading_progress_usecase.dart';

///Classe controller de la fonctionnalité de lecture audio avec gestion
/// de la pause, de la reprise et de la sauvegarde de la progression.
///
/// Elle étend la classe ChangeNotifier afin de notifier l’interface utilisateur
/// à chaque changement d’état grâce à la méthode notifyListeners().
class ReadingProgressController extends ChangeNotifier {

  // Déclaration dépendance
  final ReadingProgressUsecase readingProgressUsecase;

  ReadingProgressController({required this.readingProgressUsecase});

  //état
  bool isLoading = false; // prevenir d'une action longue est en cours. Evite que l'interface se fige
  String message = '';
  ReadingProgress? currentProgress;

  /// Charger La progression de la lecture audio
  /// depuis la derniere sauvegarde
  Future<void> loadProgress() async {
    isLoading = true;
    notifyListeners(); // informe l'interface d'un changement d'état

    currentProgress = await readingProgressUsecase.getSaveProgress();

    isLoading = false;
    notifyListeners();
  }

  ///Sauvegarder la lecture
  Future<void> saveProgress(ReadingProgress progress) async {
    isLoading = true;
    notifyListeners();

    await readingProgressUsecase.saveProgress(progress);
    currentProgress = progress;

    isLoading = false;
    notifyListeners();
  }

  /// Réinitialiser la lecture
  Future<void> resetProgress() async {
    isLoading = true;
    notifyListeners();

    await readingProgressUsecase.resetProgress();
    currentProgress = null;

    isLoading = false;
    notifyListeners();
  }
}
