import 'package:flutter/material.dart';
import 'package:leodys/common/utils/internet_util.dart';
import '../../../../common/widget/voice_text_field.dart';
import '../controllers/notification_controller.dart';
import '../../domain/entities/referent_entity.dart';

class EmailComposePage extends StatefulWidget {
  final ReferentEntity referent;
  final NotificationController controller;

  const EmailComposePage({required this.referent, required this.controller, super.key});

  @override
  State<EmailComposePage> createState() => _EmailComposePageState();
}

class _EmailComposePageState extends State<EmailComposePage> {
  final TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  void _initVoice() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Message à ${widget.referent.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            VoiceTextField(
              controller: _bodyController,
              label: "Votre message",
              maxLines: 8,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Envoyer Directement"),
              onPressed: () async {
                final hasNet = InternetUtil.isConnected;
                if (!hasNet) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(
                          "Échec : Aucune connexion internet disponible."))
                  );
                }
                await widget.controller.sendMessage(
                  referent: widget.referent,
                  subject: "Alerte Leodys",
                  body: _bodyController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email envoyé et archivé !")));
              },
            )
          ],
        ),
      ),
    );
  }

}