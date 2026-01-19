import 'package:flutter/cupertino.dart';
import '../../domain/models/document.dart';
import '../../domain/models/reader_config.dart';
import '../../domain/usecases/document_usecase.dart';
import '../../domain/usecases/read_text_usecase.dart';
import '../../domain/usecases/scan_document_usecase.dart';

///Classe controller de la fonctionnalité lecture audio.
///Il étend la classe ChangeNotifier
///afin de notifier l'interface utilisateur qu'il y a un changement d'état,
///grace à la classe notifyListeners()

class ReaderController extends ChangeNotifier {

  // Déclaration des dépendances
  final ScanDocumentUsecase scanDocumentUsecase;
  final ReadTextUseCase readTextUseCase;
  final DocumentUsecase documentUsecase;

  ReaderController({
    required this.readTextUseCase,
    required this.scanDocumentUsecase,
    required this.documentUsecase,
  });

  // état
  bool isLoading = false; // prevenir d'une action longue est en cours. Evite que l'interface se fige
  String recognizedText = ''; // Variable qui doit contenir le texte après le scan.
  String message = '';

  ///Lance le scan OCR d'un document
  Future<void> scanDocument(String imagePath) async {
    isLoading = true;
    message = '';
    notifyListeners(); // informe l'interface d'un changement d'état

    final text = await scanDocumentUsecase.scanDocument(imagePath);

    recognizedText = text;
    isLoading = false;

    if (text.trim().isEmpty) {
      message = 'Aucun texte détecté ';
    }
    notifyListeners();

    if (text.trim().isNotEmpty) {
      final document = Document(
        idText: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _generateTitle(text),
        content: text,
        createAt: DateTime.now(),
      );

      await documentUsecase.saveDocument(document);
    }

    notifyListeners();
  }

  ///Création titre pour le doucment de texte
  ///first récupere le 1er élément de la liste.
  String _generateTitle(String text){
    final line = text.split('\n').first.trim();
    if (line.length > 20){
      return line.substring(0,20);
    }
    return line;
  }

  ///Lancer la lecture vocal du texte
  Future<void> readText(ReaderConfig config) async{
    if (recognizedText.trim().isEmpty){
      message = 'Aucun texte à lire';
      notifyListeners();
      return;
    }
    await readTextUseCase.execute(recognizedText, config);
  }

  /// Charge un document existant pour lecture
  void loadDocument(Document document){
    recognizedText = document.content;
    message ='';
    notifyListeners();
  }


  Future<void>pause() async{
    await readTextUseCase.pause();
  }

  Future<void>resume(ReaderConfig config) async {
    await readTextUseCase.resume(recognizedText, config);
  }

  Future<void>stop()async {
    await readTextUseCase.stop();
  }

  ///Réinitialise la lecture
  void reset(){
    recognizedText='';
    message='';
    notifyListeners();
  }
}
