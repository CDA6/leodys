import 'package:flutter/material.dart';
import '../../../../common/widget/voice_text_field.dart';

class AddReferentDialog extends StatefulWidget {
  final List<String> categories;
  final Function(String name, String email, String category) onAdd;

  const AddReferentDialog({super.key, required this.categories, required this.onAdd});

  @override
  State<AddReferentDialog> createState() => _AddReferentDialogState();
}

class _AddReferentDialogState extends State<AddReferentDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un référent"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VoiceTextField(controller: _nameController, label: "Nom complet"),
            VoiceTextField(controller: _emailController, label: "Email"),
            const SizedBox(height: 15),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _emailController.text.contains('@')) {
              widget.onAdd(_nameController.text, _emailController.text, _selectedCategory);
              Navigator.pop(context);
            }
          },
          child: const Text("Ajouter"),
        ),
      ],
    );
  }
}