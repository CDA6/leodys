import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/settings.dart';
import '../viewmodels/settings_viewmodel.dart';

class PreviewTextWidget extends StatelessWidget {
  const PreviewTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        final settings = viewModel.settings;

        return Container(
          // Fond légèrement coloré pour distinguer la zone de prévisualisation
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header de la prévisualisation
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prévisualisation en temps réel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    // Badge avec la taille actuelle
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${settings.fontSize.toInt()}pt',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Zone de texte de prévisualisation
              Container(
                constraints: const BoxConstraints(
                  minHeight: 150,
                  maxHeight: 250,
                ),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre avec style appliqué
                      _buildPreviewText(
                        context,
                        settings,
                        'La lecture pour tous',
                        isTitle: true,
                      ),
                      const SizedBox(height: 12),

                      // Paragraphe 1
                      _buildPreviewText(
                        context,
                        settings,
                        'La lecture est une activité essentielle dans notre quotidien. '
                            'Elle nous permet d\'accéder à la connaissance et de développer notre imagination.',
                      ),
                      const SizedBox(height: 8),

                      // Paragraphe 2
                      _buildPreviewText(
                        context,
                        settings,
                        'Pour les personnes dyslexiques, certaines polices et certains '
                            'espacements facilitent grandement la lecture.',
                      ),
                    ],
                  ),
                ),
              ),

              // Footer avec informations sur les paramètres actifs
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildSettingChip(
                      context,
                      Icons.font_download,
                      settings.fontFamily,
                    ),
                    if (settings.letterSpacing > 0)
                      _buildSettingChip(
                        context,
                        Icons.format_line_spacing,
                        'Espacement: ${settings.letterSpacing.toStringAsFixed(1)}px',
                      ),
                    if (settings.lineHeight > 1.5)
                      _buildSettingChip(
                        context,
                        Icons.format_line_spacing,
                        'Hauteur: ${settings.lineHeight.toStringAsFixed(1)}x',
                      ),
                    _buildSettingChip(
                      context,
                      Icons.palette,
                      _getThemeModeLabel(settings.themeMode),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewText(
      BuildContext context,
      Settings settings,
      String text, {
        bool isTitle = false,
      }) {
    return Text(
      text,
      style: TextStyle(
        // Applique directement les paramètres du ViewModel
        fontFamily: settings.fontFamily,
        fontSize: isTitle ? settings.fontSize * 1.5 : settings.fontSize,
        letterSpacing: settings.letterSpacing,
        height: settings.lineHeight,
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        // Utilise la couleur du thème
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSettingChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeLabel(String themeMode) {
    switch (themeMode) {
      case 'dark':
        return 'Sombre';
      case 'highContrast':
        return 'Contraste élevé';
      default:
        return 'Clair';
    }
  }
}