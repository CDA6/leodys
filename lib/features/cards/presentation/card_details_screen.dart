import 'dart:io';

import 'package:flutter/material.dart';
import 'package:leodys/features/cards/domain/usecases/delete_card_usecase.dart';
import 'package:leodys/features/cards/presentation/display_cards_screen.dart';
import 'package:leodys/features/cards/presentation/edit_card_screen.dart';
import 'package:leodys/features/cards/providers.dart';

import '../domain/card_model.dart';

class CardDetailsScreen extends StatefulWidget{
  static const route = "/card_details";
  CardModel? card;

  CardDetailsScreen({
    super.key,
    this.card
  });

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  late final deleteCardUseCase = getIt<DeleteCardUsecase>();
  bool _isFront = true;



  Widget _buildCardImage() {
    final front = widget.card?.rectoPath;
    final back = widget.card?.versoPath;

    // chemin actuel selon le cote de la carte
    String? currentPath = _isFront ? front : back;

    // affichage d'un message si pas d'image/problème de chargement
    if (currentPath == null || currentPath.trim().isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            "Image indisponible",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );

    }

    return GestureDetector(
      onTap: () {
        // on flip la carte seulement si le verso existe
        if (_isFront && back != null && back.trim().isNotEmpty) {
          setState(() {
            _isFront = false;
          });
        } else if (!_isFront) {
          // Toujours revenir au recto
          setState(() {
            _isFront = true;
          });
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(currentPath),
          width: 260,
          height: 260,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Carte ${widget.card!.name}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, DisplayCardsScreen.route);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // carte image
            Card(
              color: colorScheme.surfaceContainerHighest,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildCardImage(),
              ),
            ),

            const SizedBox(height: 16),

            // recto verso
            Text(
              _isFront ? "Recto" : "Verso",
              style: textTheme.labelLarge,
            ),

            const Spacer(),

            // bouton de modification
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Modifier la carte"),
                onPressed: () async {
                  final updatedCard = await Navigator.push<CardModel>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCardScreen(card: widget.card!),
                    ),
                  );

                  if (updatedCard != null) {
                    setState(() {
                      widget.card = updatedCard;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            // bouton de suppression
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                label: Text(
                  "Supprimer la carte",
                  style: TextStyle(color: colorScheme.error),
                ),
                onPressed: () async {
                  await deleteCardUseCase.call(widget.card!);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, DisplayCardsScreen.route);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}