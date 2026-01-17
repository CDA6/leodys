import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../common/widget/tts_reader_widget.dart';
import '../controllers/notification_controller.dart';
import '../../domain/entities/message_entity.dart';

class EmailHistoryPage extends StatelessWidget {
  final NotificationController controller;
  const EmailHistoryPage({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique des messages")),
      body: FutureBuilder<List<MessageEntity>>(
        future: controller.fetchHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final history = snapshot.data!;
          if (history.isEmpty) return const Center(child: Text("Aucun message envoyé"));

          return ListView.separated(
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final msg = history[index];
              return ListTile(
                title: Text("À : ${msg.referentName}"),
                subtitle: Text("${msg.subject}\n${DateFormat('dd/MM/yyyy HH:mm').format(msg.sentAt)}"),
                isThreeLine: true,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(msg.subject)),
                          // AJOUT DU WIDGET ICI pour lire le contenu
                          TtsReaderWidget(text: "Sujet : ${msg.subject}. Message : ${msg.body}"),
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("À : ${msg.referentName}", style: TextStyle(fontWeight: FontWeight.bold)),
                            const Divider(),
                            Text(msg.body),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Fermer")
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}