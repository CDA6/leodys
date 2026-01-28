import 'package:flutter/cupertino.dart';
import '../../domain/models/reader_config.dart';
import '../../domain/usecases/scan_and_read_text_usecase.dart';

///Classe controller de la fonctionnalité scan et lecture audio.
///Il étend la classe changeNotifier
///afin de notifier l'interfaces utilisateur qu'il y a un changement d'état,
///grace à la classe notifyListeners()
class ScanAndReadTextController extends ChangeNotifier{

  final ScanAndReadTextUsecase scanAndReadTextUsecase;

  ScanAndReadTextController({
    required this.scanAndReadTextUsecase,
  });

  bool isLoading = false;
  String message = '';

  ///Lancer le scan du fichier et la lecture
  Future<void> execute (String imagePath, ReaderConfig config) async {

    isLoading = true; // prevenir d'une action longue est en cours. Evite que l'interfaces se fige
    message='';
    notifyListeners(); // informe l'interfaces d'un changement d'état

    try {
      await scanAndReadTextUsecase.execute(imagePath, config);
    }catch(e){
      message = "Imppossible de lire le document";
    }finally{
      isLoading = false;
      notifyListeners();
    }

  }
}