import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leodys/src/features/cards/data/cards_remote_datasource.dart';
import 'package:leodys/src/features/cards/data/cards_repository.dart';
import 'package:leodys/src/features/cards/domain/usecases/create_pdf_usecase.dart';
import 'package:leodys/src/features/cards/domain/usecases/upload_card_usecase.dart';
import 'package:leodys/src/features/cards/presentation/rename_card_screen.dart';
import 'package:leodys/src/features/cards/providers.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisplayCardsScreen extends ConsumerStatefulWidget {

  const DisplayCardsScreen({
    super.key,
  });

  @override
  ConsumerState<DisplayCardsScreen> createState() => _DisplayCardsScreenState();

}

class _DisplayCardsScreenState extends ConsumerState<DisplayCardsScreen> {
  List<File> savedCards = [];
  Logger logger = Logger();
  late final repository = ref.read(cardsRepositoryProvider);
  late final createPdfUsecase = ref.read(createPdfUseCaseProvider);
  final user = Supabase.instance.client.auth.currentUser;

  Future<void> loadSavedCards() async {
    final cards = await repository.getSavedCards();
    setState(() {
      savedCards = cards;
    });
  }

  Future<File?> startScan(BuildContext context) async {
    try {
      List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];
      if(pictures.isEmpty) return null;
      final pdfFile = await createPdfUsecase.call(pictures);
      final renamedFile = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RenameCardScreen(pdfFile: pdfFile)));

      if (renamedFile != null) {
        await loadSavedCards();
      }

      return renamedFile;
    } catch (e) {
      logger.e(e);
      return null;
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
          Expanded(
            child: ListView.builder(
              itemCount: savedCards.length,
              itemBuilder: (context, index) {
                final file = savedCards[index];
                return ListTile(
                  title: Text(file.path.split('/').last.split('.').first),
                  leading: Icon(Icons.picture_as_pdf),
                  onTap: () {
                    // Ouvrir le PDF avec ton lecteur favori ou un package
                  },
                );
              },
            )
          )
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final renamedFile = await startScan(context); // await ici !
            if (renamedFile != null) {
              await loadSavedCards();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Carte enregistrée avec succès.')),
              );
            }
          },
          tooltip: 'Ajouter une nouvelle carte',
          child: const Icon(Icons.add),
        )
    );
  }

}