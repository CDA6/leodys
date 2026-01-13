import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leodys/src/features/cards/providers.dart';

class RenameCardScreen extends ConsumerStatefulWidget{
  final File pdfFile;
  // final Future<void> Function(File file, String name) onSave;

  const RenameCardScreen({
    super.key,
    required this.pdfFile,
  });

  @override
  ConsumerState<RenameCardScreen> createState() => _RenameCardState();
}

class _RenameCardState extends ConsumerState<RenameCardScreen> {
  final TextEditingController _controller = TextEditingController();
  String? error;
  late final uploadCardUsecase = ref.read(uploadCardUseCaseProvider);

  Future<void> onSave(File pdfFile, String name) async {
    uploadCardUsecase.call(pdfFile, "c8395dd8-0c84-4af7-8e62-305407658d5f", name);
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

    await onSave(widget.pdfFile, newName);

    Navigator.pop(context, widget.pdfFile);
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