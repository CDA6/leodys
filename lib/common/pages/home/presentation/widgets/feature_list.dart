import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:leodys/common/theme/theme_context_extension.dart';
import 'feature_item.dart';

import 'package:leodys/common/pages/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:leodys/common/pages/home/domain/entities/app_feature.dart';

import 'package:leodys/features/audio_reader/presentation/pages/reader_screen.dart';
import 'package:leodys/features/ocr-reader/presentation/screens/handwritten_text_reader_screen.dart';
import 'package:leodys/features/ocr-reader/presentation/screens/printed_text_reader_screen.dart';

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
      description: 'Reconnaissance de texte simple',
    ),

    AppFeature(
      name: 'Scanner de texte manuscrit',
      icon: Icons.edit,
      route: HandwrittenTextReaderScreen.route,
      requiresInternet: true,
      requiresAuth: false,
      isAvailable: true,
      description: 'Reconnaissance de texte complexe',
    ),

    AppFeature(
      name: 'Scanner de jeu de carte',
      icon: Icons.view_module,
      route: '/',
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: false,
      description: 'Reconnaissance de jeu de carte classique',
    ),

    AppFeature(
      name: 'Carte',
      icon: Icons.map,
      route: '/map',
      requiresInternet: true,
      requiresAuth: false,
      isAvailable: true,
      description: 'Visualiser et naviguer sur la carte',
    ),

    AppFeature(
      name: 'Lecteur d\'écran',
      icon: Icons.speaker,
      route: ReaderScreen.route,
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: true,
      description: 'TODO',
    ),

    AppFeature(
      name: 'Lecteur de plaque d\'immatriculation',
      icon: Icons.directions_car_rounded,
      route: ReaderScreen.route,
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: false,
      description: 'TODO',
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
              _buildSectionTitle(context, 'Fonctionnalités'),
              const SizedBox(height: 12),
              _buildFeaturesGrid(context, viewModel, _features),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: context.titleFontSize,
        color: context.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, HomeViewModel viewModel, List<AppFeature> features) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.baseFontSize > 16 ? 1 : 2,
        childAspectRatio: 0.85,
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
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => AlertDialog(
        backgroundColor: context.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: context.colorScheme.outline,
            width: 1.0,
          ),
        ),
        title: Row(
          children: [
            Icon(feature.icon, color: context.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature.name,
                style: TextStyle(color: context.colorScheme.primary),
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
                color: context.colorScheme.secondary,
              ),
            if (feature.requiresAuth)
              _buildRequirement(
                icon: Icons.lock,
                label: 'Authentification requise',
                color: context.colorScheme.secondary,
              ),
            if (!feature.isAvailable)
              _buildRequirement(
                icon: Icons.construction,
                label: 'En cours de développement',
                color: context.colorScheme.secondary,
              ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: context.colorScheme.primaryContainer,
                foregroundColor: context.colorScheme.onPrimaryContainer,
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