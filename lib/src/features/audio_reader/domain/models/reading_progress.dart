
/*
Modele qui représente la progression de la lecture audio d'un texte
 */
class ReadingProgress {
  final int pageIndex; // index de la page en cours
  final int blocIndex; // index du bloc de texte de la page

  /*
  Constructeur avec des paramètres nommés grace aux '{}'
  */
  const ReadingProgress({
    required this.pageIndex,
    required this.blocIndex
  });

}
