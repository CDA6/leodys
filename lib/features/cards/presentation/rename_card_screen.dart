import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leodys/features/cards/providers.dart';

class RenameCardScreen extends ConsumerStatefulWidget{
  final List<File> imageFiles;
  late final File? pdfFile;

  RenameCardScreen({
    super.key,
    required this.imageFiles,
  });

  @override
  ConsumerState<RenameCardScreen> createState() => _RenameCardState();
}

class _RenameCardState extends ConsumerState<RenameCardScreen> {
  final TextEditingController _controller = TextEditingController();
  String? error;
  late final uploadCardUsecase = ref.read(uploadCardUseCaseProvider);
  late final createPdfUsecase = ref.read(createPdfUseCaseProvider);
  late final saveNewCardUsecase = ref.read(saveNewCardUseCaseProvider);


  Future<void> onSave(List<File> imageFiles, String name) async {
    // widget.pdfFile = await createPdfUsecase.call(widget.pictures, name);
    // if(widget.pdfFile != null) {
    //   uploadCardUsecase.call(widget.pdfFile!, "c8395dd8-0c84-4af7-8e62-305407658d5f", name);
    // }
    saveNewCardUsecase.call(imageFiles, name);
  }

  void _save() async {
    final newName = _controller.text.trim();
    if(newName.isEmpty) {
      setState(() {
        error = "Le nom de la carte est obligatoire.";
      });
      return;
    }

    setState(() => error = null);

    await onSave(widget.imageFiles, newName);

    Navigator.pop(context);
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
            if(error != null) Text(error!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
            ElevatedButton(
              onPressed: _save,
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

}