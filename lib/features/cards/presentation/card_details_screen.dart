import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leodys/features/cards/presentation/display_cards_screen.dart';
import 'package:leodys/features/cards/providers.dart';

import '../domain/card_model.dart';

class CardDetailsScreen extends ConsumerStatefulWidget{
  static const route = "/card_details";
  final CardModel? card;

  const CardDetailsScreen({
    super.key,
    this.card
  });

  @override
  ConsumerState<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends ConsumerState<CardDetailsScreen> {
  late final repository = ref.read(cardsRepositoryProvider);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte ${widget.card!.name}"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/cards');
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await repository.deleteCard(widget.card!);
                Navigator.pop(context);
                Navigator.pushNamed(context, DisplayCardsScreen.route);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text(
                'Supprimer la carte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            )

          ],
        ),
      )
    );
  }

}