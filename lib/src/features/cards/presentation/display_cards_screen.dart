import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
class DisplayCardsScreen extends StatefulWidget {
  const DisplayCardsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DisplayCardsScreenState();

}

class _DisplayCardsScreenState extends State<DisplayCardsScreen> {
  late List<File> savedCards;
  Logger logger = Logger();

  Future<List<File>> getSavedCards() async {
    final Directory output = await getApplicationDocumentsDirectory();
    final files = output.listSync(); // liste tout
    // Filtrer les PDF
    final pdfFiles = files.whereType<File>().where((f) => f.path.endsWith('.pdf')).toList();
    return pdfFiles;
  }

  Future<void> loadSavedCards() async {
    final cards = await getSavedCards();
    setState(() {
      savedCards = cards;
    });
  }

  void startScan(BuildContext context) async {
    //liste des images scannées par l'appli
    List<String> pictures;
    final pdf = pw.Document(); // path du document pour le pdf
    final Directory output = await getApplicationDocumentsDirectory();
    var now = DateTime.now(); // utilise pour Créer le nom du fichier
    String? pathFile;
    // Chemin du fichier et nom du fichier
    print('output : ' + output.toString());

    var pathFichier =
        "${output.path}/pdf-${now.day}-${now.month}${now.year}-${now.hour}-${now.minute}-${now.second}.pdf";
    pathFile = pathFichier;
    // Créer le fichier
    final file = File(pathFichier);
    try {
      // Lancer le scan
      pictures = await CunningDocumentScanner.getPictures() ?? [];
      // Si l'utilisateur annule le scan
      if (!mounted) return;
      setState(() {
        for (var picture in pictures) {
          // Créer une image à partir du fichier
          final image = pw.MemoryImage(
            File(picture).readAsBytesSync(),
          );
          pdf.addPage(pw.Page(build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          } // Center
          ));
          // Pag
        }
      });
      //ecriture du PDF et sauvegarde dans le dossier de l'application
      await file.writeAsBytes(await pdf.save());
    } catch (exception) {
      logger.e(exception); // Handle exception here
    }
  }

  @override
  void initState() {
    super.initState();
    loadSavedCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cartes de fidélité"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/home');
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: () async {
              startScan(context);
              await loadSavedCards();
            }
        , child: Text("Scanner une nouvelle carte")),
          Expanded(
            child: ListView.builder(
              itemCount: savedCards.length,
              itemBuilder: (context, index) {
                final file = savedCards[index];
                return ListTile(
                  title: Text(file.path.split('/').last),
                  leading: Icon(Icons.picture_as_pdf),
                  onTap: () {
                    // Ouvrir le PDF avec ton lecteur favori ou un package
                  },
                );
              },
            )
          ),
          ],
        ),
      ),
    );
  }

}