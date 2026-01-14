import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leodys/features/cards/presentation/card_details_screen.dart';
import 'package:leodys/features/cards/presentation/rename_card_screen.dart';
import 'package:leodys/features/cards/providers.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/card_model.dart';

class DisplayCardsScreen extends ConsumerStatefulWidget {
  static const String route = '/cards';

  const DisplayCardsScreen({
    super.key,
  });

  @override
  ConsumerState<DisplayCardsScreen> createState() => _DisplayCardsScreenState();

}

class _DisplayCardsScreenState extends ConsumerState<DisplayCardsScreen> {
  List<CardModel> savedCards = [];
  Logger logger = Logger();
  late final repository = ref.read(cardsRepositoryProvider);
  late final createPdfUsecase = ref.read(createPdfUseCaseProvider);
  final user = Supabase.instance.client.auth.currentUser;

  Future<void> loadSavedCards() async {
    final cards = await repository.getLocalUserCards();
    setState(() {
      savedCards = cards;
      print(savedCards.toString());
      for(final card in savedCards) {
        print("nom : ${card.name}");
        print("folder : ${card.folderPath}");
      }
    });
  }

  Future<File?> startScan(BuildContext context) async {
    try {
      List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];
      if(pictures.isEmpty) return null;
      
      // conversion des chemins en Files
      List<File> imageFiles = pictures.map((path) => File(path)).toList();
      // final pdfFile = await createPdfUsecase.call(pictures);
      final renamedFile = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RenameCardScreen(imageFiles: imageFiles,)));

      if (renamedFile != null) {
        await loadSavedCards();
      }
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
                final card = savedCards[index];

                return ListTile(
                  title: Text(card.name),
                  leading: Icon(Icons.card_membership),
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CardDetailsScreen(card: card,)));
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