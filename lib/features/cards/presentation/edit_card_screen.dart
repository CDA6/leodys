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

    await updateCardUseCase.execute(update);

    // Retour à l'écran précédent
    if (mounted) Navigator.pop(context);
  }

  /// Widget d'affichage d'image avec boutons scan/supprimer
  Widget _buildImage(String? path, File? newFile, bool isRecto) {
    final display = newFile != null
        ? Image.file(newFile, width: 150, height: 150, fit: BoxFit.cover)
        : (path != null && path.isNotEmpty
        ? Image.file(File(path), width: 150, height: 150, fit: BoxFit.cover)
        : Container(
      width: 150,
      height: 150,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 50),
    ));

    return Stack(
      children: [
        display,
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _scanImage(isRecto),
          ),
        ),
        if (!isRecto && (path != null || _newVerso != null))
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => setState(() {
                _newVerso = null;
                _removeVerso = true;
              }),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier la carte")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Titre modifiable
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nom de la carte",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Images recto/verso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImage(widget.card.rectoPath, _newRecto, true),
                _buildImage(widget.card.versoPath, _newVerso, false),
              ],
            ),
            const SizedBox(height: 30),

            // Bouton valider
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Valider les modifications"),
              onPressed: _submitChanges,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
