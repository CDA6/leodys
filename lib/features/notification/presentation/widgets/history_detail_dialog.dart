import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/widget/tts_reader_widget.dart';
import '../../domain/entities/message_entity.dart';

class HistoryDetailDialog extends StatelessWidget {
  final MessageEntity message;
  const HistoryDetailDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(message.subject)),
          TtsReaderWidget(text: message.body), // Réutilisation du widget common
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("À : ${message.referentName}", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Text(message.body),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer")
        )
      ],
      // ...
    );
  }
}