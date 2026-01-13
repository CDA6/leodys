import 'package:flutter/material.dart';
import 'package:leodys/src/features/audio_reader/domain/models/reader_config.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/reader_controller.dart';
import '../controllers/document_controller.dart';
import '../widgets/document_tile.dart';

class DocumentsScreen extends StatefulWidget {
  final DocumentController documentController;
  final ReaderController readerController;

  static const route = '/documents';

  const DocumentsScreen({
    super.key,
    required this.documentController,
    required this.readerController,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {

  @override
  void initState() {
    super.initState();

    widget.documentController.addListener(_onControllerChanged);
    widget.documentController.getAllDocuments();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.documentController.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.documentController;
    final readerController = widget.readerController;

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
              readerController.loadDocument(document);
              readerController.readText(
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
