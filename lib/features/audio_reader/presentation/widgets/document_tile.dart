import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/models/document.dart';

class DocumentTile extends StatelessWidget {
  final Document document;
  final VoidCallback onRead;
  final VoidCallback onDelete;

  const DocumentTile({
    required this.document,
    required this.onRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(document.title),
        subtitle: Text(
          document.createAt.toLocal().toString(),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: onRead,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
