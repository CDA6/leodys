import 'package:flutter/material.dart';
import 'package:leodys/features/accessibility/presentation/widgets/font_size_card.dart';
import 'package:leodys/features/accessibility/presentation/widgets/intro_card.dart';
import 'package:leodys/features/accessibility/presentation/widgets/letter_spacing_card.dart';
import 'package:leodys/features/accessibility/presentation/widgets/line_height_card.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/font_family_card.dart';
import '../widgets/section_title.dart';

class SettingsScreen extends StatelessWidget {
  static const String route = '/accessibility-settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres d\'accessibilité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SettingsViewModel>().resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paramètres réinitialisés'),
                ),
              );
            },
            tooltip: 'Réinitialiser',
          ),
        ],
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = viewModel.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Introduction
              IntroCard(),
              const SizedBox(height: 24),

              // Section Typographie
              SectionTitle(icon : Icons.font_download, title: 'Typographie'),
              const SizedBox(height: 8),
              FontFamilyCard(
                currentFontFamily: settings.fontFamily,
                availableFonts: SettingsViewModel.availableFonts,
                onFontSelected: (value) {
                  if (value != null) {
                    viewModel.updateFontFamily(value);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Section Taille du texte
              SectionTitle(icon : Icons.format_size, title: 'Taille du texte'),

              const SizedBox(height: 8),
              FontSizeCard(
                  fontSize: settings.fontSize,
                  minFontSize: SettingsViewModel.minFontSize,
                  maxFontSize: SettingsViewModel.maxFontSize,
                  onFontSizeChanged: viewModel.updateFontSize
              ),
              const SizedBox(height: 24),

              // Section Espacement
              SectionTitle(icon : Icons.format_line_spacing, title: 'Espacement'),
              const SizedBox(height: 8),
              LetterSpacingCard(
                  letterSpacing: settings.letterSpacing,
                  minLetterSpacing: SettingsViewModel.minLetterSpacing,
                  maxLetterSpacing: SettingsViewModel.maxLetterSpacing,
                  onLetterSpacingChanged: viewModel.updateLetterSpacing),
              const SizedBox(height: 12),
              LineHeightCard(
                  lineHeight: settings.lineHeight,
                  minLineHeight: SettingsViewModel.minLineHeight,
                  maxLineHeight: SettingsViewModel.maxLineHeight,
                  onUpdateLineHeight: viewModel.updateLineHeight),
              const SizedBox(height: 24),

              // Section Thème
              SectionTitle(icon : Icons.palette, title: 'Thème et couleurs'),
              const SizedBox(height: 8),
              _buildThemeCard(context, viewModel, settings),
              const SizedBox(height: 24),

              // Section Synthèse vocale
              SectionTitle(icon : Icons.record_voice_over, title: 'Synthèse vocale'),
              const SizedBox(height: 8),
              _buildTextToSpeechCard(context, viewModel, settings),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(
      BuildContext context,
      SettingsViewModel viewModel,
      settings,
      )
  {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mode d\'affichage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              title: 'Clair',
              description: 'Fond blanc, idéal en journée',
              icon: Icons.light_mode,
              value: 'light',
              groupValue: settings.themeMode,
              onChanged: (value) => viewModel.updateThemeMode(value!),
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              title: 'Sombre',
              description: 'Réduit la fatigue oculaire',
              icon: Icons.dark_mode,
              value: 'dark',
              groupValue: settings.themeMode,
              onChanged: (value) => viewModel.updateThemeMode(value!),
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              title: 'Contraste élevé',
              description: 'Noir sur blanc pour une lisibilité maximale',
              icon: Icons.contrast,
              value: 'highContrast',
              groupValue: settings.themeMode,
              onChanged: (value) => viewModel.updateThemeMode(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextToSpeechCard(
      BuildContext context,
      SettingsViewModel viewModel,
      settings,
      )
  {
    return Card(
      child: SwitchListTile(
        title: const Text(
          'Activer la synthèse vocale',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Lit le contenu à voix haute (maintenir appuyé sur le texte)',
        ),
        value: settings.textToSpeechEnabled,
        onChanged: (value) {
          viewModel.toggleTextToSpeech(value);
        },
        secondary: const Icon(Icons.record_voice_over),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _ThemeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}