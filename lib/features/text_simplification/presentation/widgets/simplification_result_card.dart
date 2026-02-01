import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leodys/features/text_simplification/domain/entities/text_simplification_entity.dart';
import 'package:intl/intl.dart';

/// Widget affichant le resultat d'une simplification.
class SimplificationResultCard extends StatelessWidget {
  final TextSimplificationEntity item;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool showOriginal;

  const SimplificationResultCard({
    super.key,
    required this.item,
    this.onDelete,
    this.onTap,
    this.showOriginal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tete avec date et actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(item.createdAt.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton copier
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyToClipboard(context),
                        tooltip: 'Copier le texte simplifie',
                        visualDensity: VisualDensity.compact,
                      ),
                      // Bouton supprimer
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red.shade400,
                          ),
                          onPressed: onDelete,
                          tooltip: 'Supprimer',
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),

              const Divider(),

              // Texte original (optionnel)
              if (showOriginal) ...[
                Text(
                  'Texte original:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.originalText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  'Texte simplifie:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Texte simplifie
              Text(
                item.simplifiedText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: item.simplifiedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texte copie dans le presse-papiers'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
