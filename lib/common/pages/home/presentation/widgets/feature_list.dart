import 'package:flutter/material.dart';
import 'package:leodys/common/utils/internet_util.dart';
import 'package:leodys/features/audio_reader/presentation/pages/reader_screen.dart';
import 'package:leodys/features/cards/presentation/display_cards_screen.dart';
import 'package:leodys/features/ocr-reader/presentation/screens/handwritten_text_reader_screen.dart';
import 'package:provider/provider.dart';
import '../../../../../features/ocr-reader/presentation/screens/printed_text_reader_screen.dart';
import '../../domain/entities/app_feature.dart';
import '../viewmodels/home_viewmodel.dart';
import 'feature_item.dart';

/// Widget affichant la liste des fonctionnalités disponibles.
///
/// **Configuration centralisée** : Toutes les features sont déclarées ici.
/// Pour ajouter une nouvelle feature, il suffit d'ajouter une entrée dans [_features].
class FeatureList extends StatelessWidget {
  const FeatureList({super.key});

  /// Liste de toutes les fonctionnalités de l'application.
  static const List<AppFeature> _features = [
    AppFeature(
      name: 'Scanner de texte numérique',
      icon: Icons.keyboard,
      route: PrintedTextReaderScreen.route,
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: true,
      color: Colors.blue,
      description: 'Reconnaissance de texte simple',
    ),

    AppFeature(
      name: 'Scanner de texte manuscrit',
      icon: Icons.edit,
      route: HandwrittenTextReaderScreen.route,
      requiresInternet: true,
      requiresAuth: false,
      isAvailable: true,
      color: Colors.blue,
      description: 'Reconnaissance de texte complexe',
    ),

    AppFeature(
      name: 'Scanner de jeu de carte',
      icon: Icons.view_module,
      route: '/',
      requiresInternet: true,
      requiresAuth: true,
      isAvailable: true,
      color: Colors.blue,
      description: 'Reconnaissance de jeu de carte classique',
    ),

    AppFeature(
      name: 'Carte',
      icon: Icons.map,
      route: '/map',
      requiresInternet: true,
      requiresAuth: false,
      isAvailable: true,
      color: Colors.blue,
      description: 'Visualiser et naviguer sur la carte',
    ),

    AppFeature(
      name: 'Lecteur d\'écran',
      icon: Icons.speaker,
      route: ReaderScreen.route,
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: true,
      color: Colors.blue,
      description: 'TODO',
    ),

    AppFeature(
      name: 'Scanner de cartes de fidélité',
      icon: Icons.card_membership_sharp,
      route: DisplayCardsScreen.route,
      requiresInternet: false,
      requiresAuth: true,
      isAvailable: true,
      color: Colors.blue,
      description: 'Scan de cartes de fidélité.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_features.isNotEmpty) ...[
              _buildSectionTitle('Fonctionnalités'),
              const SizedBox(height: 12),
              _buildFeaturesGrid(context, viewModel, _features),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, HomeViewModel viewModel, List<AppFeature> features) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        final isAccessible = viewModel.canUseFeature(feature);

        return FeatureItem(
          feature: feature,
          isAccessible: isAccessible,
          onTap: () => _handleFeatureTap(
            context,
            viewModel,
            feature,
            isAccessible,
          ),
        );
      },
    );
  }

  Widget _buildRequirement({required IconData icon, required String label, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFeatureTap(BuildContext context, HomeViewModel viewModel, AppFeature feature, bool isAccessible) {
    if (isAccessible) {
      Navigator.pushNamed(context, feature.route);
    }
    else {
      _showBlockedFeatureDialog(context, feature);
    }
  }

  void _showBlockedFeatureDialog(BuildContext context, AppFeature feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(feature.icon, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (feature.requiresInternet)
              _buildRequirement(
                icon: Icons.wifi,
                label: 'Connexion Internet requise',
                color: Colors.blue,
              ),
            if (feature.requiresAuth)
              _buildRequirement(
                icon: Icons.lock,
                label: 'Authentification requise',
                color: Colors.blue,
              ),
            if (!feature.isAvailable)
              _buildRequirement(
                icon: Icons.construction,
                label: 'En cours de développement',
                color: Colors.blue,
              ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Compris'),
            ),
          )
        ],
      ),
    );
  }

}