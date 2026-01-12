
import 'package:leodys/src/features/audio_reader/domain/models/reader_config.dart';

/*
Classe abstraite ttsRepository qui représente une interface.
Elle définit les contrats que les classes de la couche data devront implémenter
 */
abstract class TtsRepository{

  /*
  Méthodes pour lancer la lecture audio du texte
  en utilisant la configuration choisie
   */
  Future<void> speak(String text, ReaderConfig config);

  /*
  Mettre en pause la lecture
   */
  Future<void> pause();

  /*
  Reprendre la lecture apres une pause
   */
  Future<void> resume(String text, ReaderConfig config);

  /*
  Arrêter la lecture
   */
  Future<void> stop();
}