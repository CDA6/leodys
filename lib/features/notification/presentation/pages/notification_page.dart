import 'package:flutter/material.dart';
import '../../../../common/widget/voice_text_field.dart';
import '../../../notification/notification_injection.dart';
import '../controllers/notification_controller.dart';
import '../widgets/referent_list_tile.dart';
import '../widgets/add_referent_dialog.dart';
import '../../domain/entities/referent_entity.dart';
import '../controllers/voice_controller.dart';
import 'email_compose_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  final TextEditingController _bodyController = TextEditingController();
  final VoiceController _voiceController = VoiceController();
  bool _speechEnabled = false;

  final controller = sl<NotificationController>();
  final List<String> categories = ['Mon Référent', 'CAP Emploi', 'AGEFIPH'];

  @override
  void initState() {
    super.initState();
    _voiceController.initSpeech();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Contacts Référents"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AddReferentDialog(
                categories: categories,
                onAdd: (name, email, cat) async {
                  await controller.addReferent(name, email, cat);
                  _refresh();
                },
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<ReferentEntity>>(
        future: controller.fetchReferents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [];

          return ListView(
            children: categories.map((cat) {
              final refsInCategory = data.where((r) => r.category == cat).toList();
              if (refsInCategory.isEmpty && cat != 'Mon Référent') return const SizedBox.shrink();

              return ExpansionTile(
                initiallyExpanded: true,
                title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                children: refsInCategory.map((ref) => ReferentListTile(
                  referent: ref,
                  onDelete: () async {
                    await controller.removeReferent(ref.id);
                    _refresh();
                  },
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailComposePage(referent: ref, controller: controller),
                    ),
                  ),
                )).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Nécessaire pour mettre à jour le dropdown dans le dialog
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Ajouter un référent"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VoiceTextField(
                  controller: nameController,
                  label: "Nom complet",
                  maxLines: 1,
                ),
                VoiceTextField(
                  controller: emailController,
                  label: "Email",
                  maxLines: 1,
                ),
                const SizedBox(height: 15),
                DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setDialogState(() => selectedCategory = newValue!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && emailController.text.contains('@')) {
                  await controller.addReferent(
                    nameController.text,
                    emailController.text,
                    selectedCategory,
                  );
                  Navigator.pop(context);
                  _refresh(); // Rafraîchit la liste principale
                }
              },
              child: const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleListening() {
    if (_voiceController.isListening) {
      _voiceController.stopListening();
    } else {
      _voiceController.startListening((text) {
        setState(() => _bodyController.text = text);
      });
    }
    setState(() {});
  }
}