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
    try {
      final cards = await getLocalCards.call(null);
      cards.fold(
              (failure) {
            return SnackBar(content: Text("Erreur lors du chargement des cartes. Réessayez ultérieurement."));
          },
              (cards) {
            setState(() {
              savedCards = cards;
            });
          });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> startScan(BuildContext context) async {
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
        body: Padding(
          padding: const EdgeInsets.all(12),
          // si aucune carte enregistrée
          child: savedCards.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.credit_card_off,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  "Aucune carte enregistrée",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Appuyez sur + pour en ajouter une",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),
          )
              // si au moins une carte enregistrée
              : ListView.separated(
            itemCount: savedCards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final card = savedCards[index];
              return Card(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.card_membership,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(card.name),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CardDetailsScreen(card: card),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
              // ouvre l'écran de scan puis de renommage
              final newCard = await startScan(context);

              // si carte bien créee
              if (newCard != null) {
                // refresh de la liste
                await loadSavedCards();
              }
          },
          tooltip: 'Ajouter une nouvelle carte',
          child: const Icon(Icons.add),
        )

    );
  }

}