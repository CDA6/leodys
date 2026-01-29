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

    // affichage d'un message si pas d'image
    if (currentPath == null || currentPath.trim().isEmpty) {
      return const Text("Image indisponible");
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
            _buildCardImage(),

            const SizedBox(height: 20),

            Text(
              _isFront ? "Recto" : "Verso",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await deleteCardUseCase.call(widget.card!);
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
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final updatedCard = await Navigator.push<CardModel>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCardScreen(card: widget.card!),
                  ),
                );

                // si carte mise à jour, affichage de la nouvelle + rafraichissement de la page
                if (updatedCard != null) {
                  setState(() {
                    widget.card = updatedCard;
                  });
                }
              },
              icon: const Icon(Icons.update),
              label: const Text(
                'Modifier la carte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade500,
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
      ),
    );
  }

}