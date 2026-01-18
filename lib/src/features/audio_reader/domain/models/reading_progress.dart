/// Modele qui représente la progression de la lecture audio d'un texte
/// Permet de reprendre la lecture audio à partir d'un paragraphe ou une page
class ReadingProgress {
  final int pageIndex; // index de la page en cours
  final int blocIndex; // index du bloc de texte de la page

  const ReadingProgress({required this.pageIndex, required this.blocIndex});
}
