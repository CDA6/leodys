import 'package:flutter/material.dart';
import '../../domain/entities/reader_config.dart';
import '../controllers/web_reader_controller.dart';
import 'selectable_web_reader_screen.dart';

class WebReaderScreen extends StatefulWidget {
  final WebReaderController controller;
  static const String route = "/web-reader";

  const WebReaderScreen({super.key, required this.controller});

  @override
  State<WebReaderScreen> createState() => _WebReaderScreenState();
}

class _WebReaderScreenState extends State<WebReaderScreen> {
  final List<String> _sites = [
    'https://www.service-public.fr',
    'https://www.agefiph.fr',
    'https://www.handicap.gouv.fr',
  ];

  String _selectedSite = 'https://www.service-public.fr';

  final ReaderConfig config = ReaderConfig(
    languageCode: "fr-FR",
    speechRate: 0.45,
    pitch: 1.0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lecteur de site gouvernemental',
            style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSite,
                decoration: InputDecoration(
                  labelText: 'Choisir un site',
                  border: const OutlineInputBorder(),
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                items: _sites
                    .map((site) => DropdownMenuItem(
                  value: site,
                  child: Text(site.replaceAll('https://www.', ''),
                      style: theme.textTheme.bodyMedium),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSite = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Instructions card
              Card(
                color: theme.colorScheme.primary.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Comment utiliser la sélection',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                          context,
                          '1',
                          'Appuyez sur "Sélectionner du texte" ci-dessous'),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                          context,
                          '2',
                          'Appuyez longuement sur un mot pour commencer la sélection'),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                          context,
                          '3',
                          'Faites glisser votre doigt pour sélectionner plus de texte'),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                          context,
                          '4',
                          'Relâchez pour terminer la sélection'),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                          context,
                          '5',
                          'Appuyez sur le bouton "Lire" pour écouter le texte sélectionné'),
                      const SizedBox(height: 12),

                      // Tip with read button
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                size: 20, color: theme.colorScheme.secondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Astuce : Vous pouvez ajuster la sélection en déplaçant les poignées bleues',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.volume_up,
                                  color: theme.colorScheme.secondary),
                              onPressed: () {
                                widget.controller.readTextUseCase.execute(
                                  'Astuce : Vous pouvez ajuster la sélection en déplaçant les poignées bleues',
                                  config,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Button to open selection screen
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectableWebReaderScreen(
                          controller: widget.controller,
                          config: config,
                          url: _selectedSite,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.touch_app,
                      size: 24, color: theme.colorScheme.onPrimary),
                  label: Text(
                    'Sélectionner du texte',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(BuildContext context, String number, String text) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: Icon(Icons.volume_up, color: theme.colorScheme.primary),
          onPressed: () {
            widget.controller.readTextUseCase.execute(text, config);
          },
        ),
      ],
    );
  }
}
