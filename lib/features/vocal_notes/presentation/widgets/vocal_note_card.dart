import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/features/vocal_notes/domain/entities/vocal_note_entity.dart';

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
          backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.mic, color: context.colorScheme.primary),
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
              style: TextStyle(color: context.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: TextStyle(fontSize: 12, color: context.colorScheme.primary),
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
              icon: Icon(Icons.delete_outline, color: context.stateColors.error),
              onPressed: onDelete,
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }
}
