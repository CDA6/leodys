import 'dart:io';

import 'package:flutter/material.dart';
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

  Future<void> onSave(
      List<File> imageFiles,
      String name,
      SaveNewCardUsecase saveNewCardUsecase,
      ) async {
    await saveNewCardUsecase.call(imageFiles, name);
  }

  void _save(SaveNewCardUsecase saveNewCardUsecase) async {
    final newName = _controller.text.trim();

    if (newName.isEmpty) {
      setState(() {
        error = "Le nom de la carte est obligatoire.";
      });
      return;
    }

    setState(() => error = null);

    await onSave(widget.imageFiles, newName, saveNewCardUsecase);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final saveNewCardUsecase = getIt<SaveNewCardUsecase>();

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
              onPressed: () => _save(saveNewCardUsecase),
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
