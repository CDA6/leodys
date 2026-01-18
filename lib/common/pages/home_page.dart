import 'package:flutter/material.dart';

import '../../features/map/presentation/screen/map_screen.dart';
import '../../features/notification/presentation/pages/notification_dashboard_page.dart';
import '../../features/ocr-reader/presentation/screens/ocr_type_selection.dart';
import '../../features/vocal_notes/presentation/screens/vocal_notes_list_screen.dart';
import '../widget/feature_item.dart';
import '../widget/global_appbar.dart';

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
                  crossAxisCount: 3,
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
                        Navigator.pushNamed(
                          context,
                          OcrTypeSelectionScreen.route,
                        );
                      },
                    ),
                    FeatureItem(
                      icon: Icons.message,
                      label: 'Messagerie',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          NotificationDashboard.route,
                        );
                      },
                    ),
                    FeatureItem(
                      icon: Icons.mic,
                      label: 'Notes vocales',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          VocalNotesListScreen.route,
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
    );
  }
}
