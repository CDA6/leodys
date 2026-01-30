import 'package:flutter/material.dart';

import '../../domain/models/document.dart';

class DocumentTile extends StatelessWidget {

  // VoidCallback est une fonction qui ne retourne rien
  // Son role sera attribué plus tard en lui donnant une implémentation
  final Document document;
  final VoidCallback onRead;
  final VoidCallback onDelete;
  final VoidCallback onStop;
  final VoidCallback onPause;

  const DocumentTile({super.key,
    required this.document,
    required this.onRead,
    required this.onDelete,
    required this.onStop,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Card( // conteneur visuel
      child: ListTile( // Structure les éléments intérieur organisés en ligne
        title: Text(document.title),
        subtitle: Text(
          document.createAt.toLocal().toString(), // date de création
          style: const TextStyle(fontSize: 12),
        ),
        // trailing affiche les actions à droite
        trailing: Row( // structuré en ligne
          mainAxisSize: MainAxisSize.min, // prendre le minimum de place
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: onRead,
            ),
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: onPause,
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: onStop,
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
