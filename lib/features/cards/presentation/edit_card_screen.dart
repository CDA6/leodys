import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leodys/features/cards/domain/card_model.dart';
import 'package:leodys/features/cards/domain/card_update_model.dart';
import 'package:leodys/features/cards/providers.dart';

import '../domain/usecases/update_card_usecase.dart';
import '../services/scan_service.dart';

class EditCardScreen extends StatefulWidget {
  final CardModel card;

  const EditCardScreen({
    super.key,
    required this.card
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final scanService = getIt<ScanService>();
  late TextEditingController _nameController;
  File? _newRecto;
  File? _newVerso;
  bool _removeVerso = false;
  final updateCardUseCase = getIt<UpdateCardUsecase>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card.name);
  }

  /// Lancer le scanner et remplacer l'image
  Future<void> _scanImage(bool isRecto) async {
    final scannedFile = await scanService.scanDocument();
    if (scannedFile != null) {
      setState(() {
        if (isRecto) {
          _newRecto = scannedFile;
        } else {
          _newVerso = scannedFile;
          _removeVerso = false; // si on scanne un verso, on annule la suppression
        }
      });
    }
  }

  /// Soumettre les modifications
  Future<void> _submitChanges() async {
    final update = CardUpdateModel(
      card: widget.card,
      newName: _nameController.text != widget.card.name
          ? _nameController.text
          : null,
      newRecto: _newRecto,
      newVerso: _newVerso,
      removeVerso: _removeVerso,
    );

    final result = await updateCardUseCase.call(update);

    result.fold(
          (failure) {
        // SnackBar d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
          (updatedCard) {
        // SnackBar succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Carte mise à jour avec succès !")),
        );

        // pop vers la page précédente
        Navigator.pop(context, updatedCard);
      },
    );
  }

  /// Widget d'affichage d'image avec boutons scan/supprimer
  Widget _buildImage(String? path, File? newFile, bool isRecto) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget image;

    if (newFile != null) {
      image = Image.file(newFile, fit: BoxFit.cover);
    } else if (path != null && path.isNotEmpty) {
      image = Image.file(File(path), fit: BoxFit.cover);
    } else {
      image = Icon(
        Icons.image,
        size: 48,
        color: colorScheme.onSurfaceVariant,
      );
    }

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Center(child: image),

          // bouton de scan recto
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
              icon: Icon(Icons.camera_alt, color: colorScheme.primary),
              onPressed: () => _scanImage(isRecto),
            ),
          ),

          // verso
          if (!isRecto && (path != null || _newVerso != null))
            Positioned(
              bottom: 4,
              right: 4,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
                icon: Icon(Icons.delete_forever, color: colorScheme.error),
                onPressed: () => setState(() {
                  _newVerso = null;
                  _removeVerso = true;
                }),
              ),
            ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier la carte"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // carte principale
            Card(
              color: colorScheme.surfaceContainerHighest,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // titre
                    Text(
                      "Informations de la carte",
                      style: textTheme.titleMedium,
                    ),

                    const SizedBox(height: 16),

                    // nom de la carte
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Nom de la carte",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // recto/verso de la carte
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImage(
                          widget.card.rectoPath,
                          _newRecto,
                          true,
                        ),
                        _buildImage(
                          widget.card.versoPath,
                          _newVerso,
                          false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // bouton d'enregistrement
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Valider les modifications"),
                onPressed: _submitChanges,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
