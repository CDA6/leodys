import 'package:flutter/material.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import '../../domain/entities/card_entity.dart';

class CardResultsSection extends StatelessWidget {
  final List<CardEntity> cards;

  const CardResultsSection({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.stateColors.success.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.stateColors.success),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cards.length == 1 ? '1 carte détectée' : '${cards.length} cartes détectées',
                  style: TextStyle(
                    fontSize: context.baseFontSize,
                    fontWeight: FontWeight.bold,
                    color: context.stateColors.success,
                    letterSpacing: context.letterSpacing,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Cartes
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cards.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              return _buildGameCard(context, card, index + 1);
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Détails
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: context.colorScheme.onSurfaceVariant,
          title: Text(
            'Détails des cartes (${cards.length})',
            style: TextStyle(
              fontSize: context.baseFontSize,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return _buildDetailedCardTile(context, card, index + 1);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 72),

      ],
    );
  }

  // Carte style
  Widget _buildGameCard(BuildContext context, CardEntity card, int number) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 140,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colorScheme.outline,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Symbole
          Text(
            card.symbol,
            style: TextStyle(
              fontSize: 40,
              color: card.suit.color,
              fontFamily: 'CardSuits',
            ),
          ),

          const SizedBox(height: 8),
          // Valeur
          Text(
            card.value.fr,
            style: TextStyle(
              fontSize: context.titleFontSize,
              letterSpacing: context.letterSpacing,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Détails
  Widget _buildDetailedCardTile(BuildContext context, CardEntity card, int number) {
    final confidencePercent = (card.confidence * 100).round();
    final confidenceColor = _getConfidenceColor(context, card.confidence);

    return Card(
      color: context.colorScheme.surfaceContainerHighest,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outline, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Symbole
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    card.symbol,
                    style: TextStyle(
                      fontSize: 24,
                      color: card.suit.color,
                      fontFamily: 'CardSuits',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Nom de la carte
                Expanded(
                  child: Text(
                    card.name,
                    style: TextStyle(
                      fontSize: context.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurfaceVariant,
                      letterSpacing: context.letterSpacing,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                // Confiance
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: confidenceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: confidenceColor.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text(
                        '$confidencePercent%',
                        style: TextStyle(
                          fontSize: context.baseFontSize * 0.9,
                          color: confidenceColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Lecture tff
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.colorScheme.outline),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        size: context.baseFontSize * 1.5,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => _speakCardName(context, card.name),
                      tooltip: 'Lire le nom de la carte',
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode temporaire le temps d'avoir une solution globale pour lire du texte
  void _speakCardName(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lecture vocale: $text'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getConfidenceColor(BuildContext context, double confidence) {
    if (confidence >= 0.75) return context.stateColors.success;
    if (confidence >= 0.65) return context.stateColors.warning;
    return context.stateColors.error;
  }
}
