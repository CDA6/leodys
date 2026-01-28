import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:leodys/features/gamecards-reader/data/datasource/card_model_datasource.dart';
import 'package:path_provider/path_provider.dart';

// Imports de tes modules
import 'features/object_detection/data/domestic_model_service.dart';

void main() {
  runApp(const MaterialApp(home: AITesterPage()));
}

class AITesterPage extends StatefulWidget {
  const AITesterPage({super.key});

  @override
  State<AITesterPage> createState() => _AITesterPageState();
}

class _AITesterPageState extends State<AITesterPage> {
  String _logs = "Prêt à tester...";

  // Instance de tes datasource
  final _cardService = CardModelDatasource();
  final _objectService = DomesticModelService(); // on se fiche de ce model, concentrons nous sur CardModelService

  void log(String message) {
    setState(() {
      _logs += "\n$message";
    });
    print(message);
  }

  // Outil pour convertir l'asset en File (car ton service attend un File)
  Future<File> _assetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/temp_image.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  Future<void> _testCardService() async {
    log("--- TEST SERVICE CARTES ---");
    try {
      log("1. Chargement du modèle...");
      await _cardService.loadModel();
      log("✅ Modèle chargé.");

      log("2. Préparation de l'image de test...");
      // ASSURE-TOI D'AVOIR UNE IMAGE assets/test_carte.jpg
      final file = await _assetToFile('assets/images/carte_test.jpg');

      log("3. Inférence...");
      final results = await _cardService.predict(file);

      log("✅ Succès ! ${results.length} détections :");
      for (var r in results) {
        log(" - ${r.label} (${(r.confidence * 100).toStringAsFixed(1)}%)");
      }
    } catch (e) {
      log("❌ ERREUR : $e");
    } finally {
      _cardService.dispose();
    }
  }

  Future<void> _testDomesticLoadOnly() async {
    log("--- TEST SERVICE OBJETS (Load Only) ---");
    // On ne peut pas tester predict() facilement sans CameraImage,
    // mais on peut au moins vérifier que le fichier .tflite est valide.
    try {
      log("1. Chargement du modèle...");
      await _objectService.loadModel();
      log("✅ Modèle chargé avec succès (Le fichier .tflite est bon).");
      log("Note: Impossible de tester 'predict' sans flux caméra réel.");
    } catch (e) {
      log("❌ ERREUR : $e");
    } finally {
      _objectService.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Banc d'essai IA")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: _testCardService,
                  child: const Text("Tester Cartes")
              ),
              ElevatedButton(
                  onPressed: _testDomesticLoadOnly,
                  child: const Text("Tester Objets")
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black12,
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(child: Text(_logs)),
            ),
          ),
        ],
      ),
    );
  }
}