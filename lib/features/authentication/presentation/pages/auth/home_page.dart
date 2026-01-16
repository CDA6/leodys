import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../common_widgets/appbar/global_appbar.dart';
import '../../../../../common_widgets/feature_item.dart';
import '../../../../map/presentation/screen/map_screen.dart';
import '../../../../ocr-reader/presentation/screens/ocr_type_selection.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(title: 'Accueil'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, size: 100, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Bienvenue sur Leodys',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Cette application est accessible sans connexion.\n'
                    'Cliquez sur "Se connecter" dans la barre du haut pour vous authentifier.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // Nombre de colonnes
                  children: [
                    FeatureItem(
                      icon: Icons.map,
                      label: 'Carte',
                      onTap: () {
                        Navigator.pushNamed(context, MapScreen.route);
                      },
                    ),
                    FeatureItem(
                      icon: Icons.camera_alt,
                      label: 'OCR Reader',
                      onTap: () {
                        Navigator.pushNamed(context, OcrTypeSelectionScreen.route);
                      },
                    ),
                    FeatureItem(
                      icon: Icons.mic,
                      label: 'Voice Clock',
                      onTap: () {
                        // Navigue vers la route appropriée pour Voice Clock
                        Navigator.pushNamed(context, '/voice-clock');
                      },
                    ),
                    // Ajoutez d'autres fonctionnalités ici
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}