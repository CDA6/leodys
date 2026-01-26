import 'dart:io';

import 'package:flutter/material.dart';
import 'package:leodys/features/cards/domain/usecases/params/save_new_card_params.dart';
import 'package:leodys/features/cards/providers.dart';

import '../domain/usecases/save_new_card_usecase.dart';

class RenameCardScreen extends StatefulWidget{
  final List<File> imageFiles;
  late final File? pdfFile;

  RenameCardScreen({
    super.key,
    required this.imageFiles,
  });

  @override
  State<RenameCardScreen> createState() => _RenameCardState();
}

class _RenameCardState extends State<RenameCardScreen> {
  final TextEditingController _controller = TextEditingController();
  String? error;
  final saveNewCardUsecase = getIt<SaveNewCardUsecase>();

  Future<void> onSave(List<File> imageFiles, String name) async {
    final params = SaveNewCardParams(imageFiles, name);
    final result = await saveNewCardUsecase.call(params);

    result.fold(
          (failure) {
        // affichage d'une snackbar en cas d'échec
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${failure.message}"),
            backgroundColor: Colors.red,
          ),
        );
      },
          (card) {
        // affichage d'une snackbar de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Carte '${card.name}' enregistrée avec succès !"),
            backgroundColor: Colors.green,
          ),
        );

        // retourne au précédent écran et passe la carte créée
        Navigator.pop(context, card);
      },
    );
  }


  void _save() async {
    final newName = _controller.text.trim();

    if (newName.isEmpty) {
      setState(() {
        error = "Le nom de la carte est obligatoire.";
      });
      return;
    }

    setState(() => error = null);

    await onSave(widget.imageFiles, newName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nommer la carte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Nom de la carte",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ElevatedButton(
              onPressed: () => _save(),
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
