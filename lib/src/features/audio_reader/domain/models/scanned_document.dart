

/*
Modele représentant un document structuré en pages, chaque page contenant des blocs de texte.
L'objectif est de permettre une lecture progressive et controlée
 */
class ScannedDocument {

  final List<ScannedPage> pages; // Liste des pages

  const ScannedDocument({required this.pages});
}

class ScannedPage {

  final List<TextBloc> blocs; // Listes des blocs de texte dans une page

  const ScannedPage({required this.blocs});
}

class TextBloc {

  final String text; // Contenue textuel du bloc

  const TextBloc({required this.text});
}
