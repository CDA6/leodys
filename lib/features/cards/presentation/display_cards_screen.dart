import 'dart:io';

import 'package:flutter/material.dart';
import 'package:leodys/features/cards/domain/usecases/get_local_user_cards_usecase.dart';
import 'package:leodys/features/cards/presentation/card_details_screen.dart';
import 'package:leodys/features/cards/presentation/rename_card_screen.dart';
import 'package:leodys/features/cards/providers.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../common/pages/home/presentation/screens/home_page.dart';
import '../domain/card_model.dart';
import '../services/scan_service.dart';

class DisplayCardsScreen extends StatefulWidget {
  static const String route = '/cards';

  const DisplayCardsScreen({
    super.key,
  });

  @override
  State<DisplayCardsScreen> createState() => _DisplayCardsScreenState();

}

class _DisplayCardsScreenState extends State<DisplayCardsScreen> {
  List<CardModel> savedCards = [];
  Logger logger = Logger();
  late final getLocalCards = getIt<GetLocalUserCardsUsecase>();
  final user = Supabase.instance.client.auth.currentUser;
  final scanService = getIt<ScanService>();

  Future<void> loadSavedCards() async {
    final cards = await getLocalCards.call();
    setState(() {
      savedCards = cards;
    });
  }

  Future<File?> startScan(BuildContext context) async {
    try {
      // conversion des chemins en Files
      List<File> imageFiles = await scanService.scanMultipleDocuments();
      final renamedFile = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RenameCardScreen(imageFiles: imageFiles,)));

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
            Navigator.pushNamed(context, HomePage.route);
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