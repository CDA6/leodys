import 'package:flutter/material.dart';
import '../../../../common/theme/theme_context_extension.dart';
import '../../domain/models/reader_config.dart';
import '../../injection.dart';
import '../controllers/document_controller.dart';
import '../controllers/reader_controller.dart';
import '../widgets/document_tile.dart';

class DocumentsScreen extends StatefulWidget {
  static const route = '/documents';

  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late final DocumentController documentController;
  late final ReaderController readerController;

  @override
  void initState() {
    super.initState();
    readerController = createReaderController();
    documentController = createDocumentController();

    documentController.getAllDocuments();
  }

  @override
  void dispose() {
    readerController.dispose();
    documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: documentController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Mes documents',
              style: TextStyle(
                color: context.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: context.colorScheme.primaryContainer,
          ),
          // Opérateur conditionnel:
          // si ca charge alors affiche CircularProgressIndicator
          body: documentController.isLoading
              ? const Center(child: CircularProgressIndicator())
          // Sinon si le chargement est fini mais pas de document
              : documentController.documents.isEmpty
          // affiche un message
              ? const Center(child: Text('Aucun document enregistré'))
          // ou sinon affiche la liste des documents
              : ListView.builder( // Construire les éléments un par un
                  // Affiche les documents ligne par ligne
                  itemCount: documentController.documents.length,
                  itemBuilder: (context, index) {
                    // Construire les lignes pour chaque document à l'index correspondant
                    final document = documentController.documents[index];

                    // Retourne les document scannés en ligne
                    // et les actions que l'utilisateur peut effectuer
                    return DocumentTile(
                      document: document,
                      onRead: () {
                        readerController.loadDocument(document);
                        readerController.readText(ReaderConfig.defaultConfig);
                      },
                      onPause: () {
                        readerController.pause();
                      },
                      onStop: () {
                        readerController.stop();
                      },
                      onDelete: () {
                        documentController.deleteDocument(document.idText);
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
