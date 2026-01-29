import 'package:flutter/material.dart';
import '../../domain/entities/reader_config.dart';
import '../controllers/web_reader_controller.dart';

class WebReaderScreen extends StatefulWidget {
  final WebReaderController controller;
  static const String route = "/web-reader";

  const WebReaderScreen({super.key, required this.controller});

  @override
  State<WebReaderScreen> createState() => _WebReaderScreenState();
}

class _WebReaderScreenState extends State<WebReaderScreen> {
  // The three government sites
  final List<String> _sites = [
    'https://www.service-public.fr',
    'https://www.agefiph.fr',
    'https://www.handicap.gouv.fr',
  ];

  String _selectedSite = 'https://www.service-public.fr';

  final ValueNotifier<bool> _isReadingNotifier = ValueNotifier(false);

  final ReaderConfig config = ReaderConfig(
    languageCode: "fr-FR",
    speechRate: 0.45,
    pitch: 1.0,
  );

  @override
  void dispose() {
    _isReadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecteur de site gouvernemental')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown for the 3 sites
            DropdownButtonFormField<String>(
              value: _selectedSite,
              decoration: const InputDecoration(
                labelText: 'Choisir un site',
                border: OutlineInputBorder(),
              ),
              items: _sites
                  .map((site) => DropdownMenuItem(
                value: site,
                child: Text(site.replaceAll('https://www.', '')),
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
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _isReadingNotifier,
              builder: (context, isReading, _) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: !isReading ? _startReading : null,
                      child: const Text('Lire le site'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isReading ? _pauseReading : null,
                      child: const Text('Pause'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isReading ? _stopReading : null,
                      child: const Text('Arrêter'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startReading() {
    _isReadingNotifier.value = true;

    widget.controller.readWebsite(
      _selectedSite,
      config,
      onReadingComplete: () {
        _isReadingNotifier.value = false;
      },
    );
  }

  void _pauseReading() {
    widget.controller.pauseReading();
    _isReadingNotifier.value = false;
  }

  void _stopReading() {
    widget.controller.stopReading();
    _isReadingNotifier.value = false;
  }
}
