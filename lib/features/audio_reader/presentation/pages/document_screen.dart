import 'package:flutter/material.dart';
import '../../domain/models/reader_config.dart';
import '../../injection.dart';
import '../controllers/document_controller.dart';
import '../controllers/reader_controller.dart';
import '../widgets/document_tile.dart';

class DocumentsScreen extends StatefulWidget {

  static const route = '/documents';

  const DocumentsScreen({
    super.key,
  });

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

    readerController.addListener(_onControllerChanged);
    documentController.addListener(_onControllerChanged);
    documentController.getAllDocuments();
  }


  /// Méthode appelée lorsque l’état d’un contrôleur change.
  /// Elle force la reconstruction de l’interface.
  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    readerController.removeListener(_onControllerChanged);
    documentController.removeListener(_onControllerChanged);

    readerController.dispose();
    documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = documentController;
    final readController = readerController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes documents'),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.documents.isEmpty
          ? const Center(child: Text('Aucun document enregistré'))
          : ListView.builder(
        itemCount: controller.documents.length,
        itemBuilder: (context, index) {
          final document = controller.documents[index];
          return DocumentTile(
            document: document,
            onRead: () {
              readController.loadDocument(document);
              readController.readText(
                ReaderConfig.defaultConfig,
              );
            },
            onDelete: () {
              controller.deleteDocument(document.idText);
            },
          );
        },
      ),
    );
  }
}
