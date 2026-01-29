/// Classe abstraite OcrRepository représente une interface.
/// Elle définit un contrat que les classes de la couche data devront implémenter
abstract class PlateOcrRepository {

  ///  Méthode asynchrone qui retourne une chaine de caracteres reconnu dans l'image
  ///  imagePath est le chemin de l'image à analyser
  Future<String?> extractTextFromImage(String imagePath);
}