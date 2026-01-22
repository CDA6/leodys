import 'package:flutter/material.dart';
import 'package:leodys/features/vocal_notes/domain/entities/vocal_note_entity.dart';
import 'package:intl/intl.dart';

class VocalNoteCard extends StatelessWidget {
  final VocalNoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPlay;

  const VocalNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    // Format de date: "18 janv. 2026 à 15:30"
    final dateStr = DateFormat(
      'dd MMM yyyy à HH:mm',
      'fr_FR',
    ).format(note.createdAt.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(Icons.mic, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: onPlay,
              tooltip: 'Lire',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }
}
