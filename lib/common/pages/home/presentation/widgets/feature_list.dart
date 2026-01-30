import 'package:flutter/material.dart';
import 'package:leodys/features/gamecards-reader/presentation/screens/gamecard_reader_screen.dart';
import 'package:leodys/features/money_manager/presentation/views/money_manager_view.dart';
import 'package:provider/provider.dart';

import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/features/audio_reader/presentation/pages/reader_screen.dart';
import 'package:leodys/features/confidential_document/presentation/confidential_document_screen.dart';
import 'package:leodys/features/forum/presentation/screens/forum_screen.dart';
import 'package:leodys/features/ocr-reader/presentation/screens/handwritten_text_reader_screen.dart';
import 'package:leodys/features/vocal_notes/presentation/screens/vocal_notes_list_screen.dart';
import 'package:leodys/features/vocal_chat/presentation/screens/vocal_chat_screen.dart';
import 'package:leodys/features/ocr-ticket-caisse/presentation/pages/receipt_page.dart';
import 'package:leodys/features/profile/presentation/screens/profile_screen.dart';
import '../../../../../features/cards/presentation/display_cards_screen.dart';
import '../../../../../features/left_right/presentation/real_time_yolo_screen.dart';
import '../../../../../features/ocr-reader/presentation/screens/printed_text_reader_screen.dart';
import '../../../../../features/vehicle_recognition/presentation/pages/scan_immatriculation_screen.dart';
import '../../../../../features/web_audio_reader/presentation/pages/web_reader_screen.dart';
import '../../domain/entities/app_feature.dart';
import '../viewmodels/home_viewmodel.dart';
import 'feature_item.dart';
import 'package:leodys/features/calculator/presentation/views/calculator_view.dart';

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
      route: GamecardReaderScreen.route,
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: true,
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
      name: 'Messagerie',
      icon: Icons.message,
      route: '/messagerie',
      requiresInternet: true,
      requiresAuth: true,
      isAvailable: true,
      description: 'Envoyer des notifications par mail',
    ),
    AppFeature(
      name: 'Horloge',
      icon: Icons.access_time,
      route: '/voice-clock',
      requiresInternet: true,
      requiresAuth: false,
      isAvailable: true,
      description: "Ecouter l'heure",
    ),

    AppFeature(
      name: 'Lecteur d\'écran',
      icon: Icons.speaker,
      route: ReaderScreen.route,
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: true,
      description: 'Lecture vocal d\'un texte scanné à partir d\'une photo',
    ),

    AppFeature(
      name: 'Reconnaissance d\'immatriculation',
      icon: Icons.directions_car,
      route: ScanImmatriculationScreen.route,
      requiresInternet: true,
      requiresAuth: false,
      isAvailable: true,
      description: 'Afficher les informations d\'un véhicule à partir d\'une plaque d\'immatriculation',
    ),

    AppFeature(
      name: 'Scanner de cartes de fidélité',
      icon: Icons.card_membership_sharp,
      route: DisplayCardsScreen.route,
      requiresInternet: false,
      requiresAuth: true,
      isAvailable: true,
      description: 'Scan de cartes de fidélité.',
    ),

    AppFeature(
      name: 'Notes Vocales',
      icon: Icons.mic_none,
      route: VocalNotesListScreen.route,
      requiresInternet: true,
      requiresAuth: false,
      isAvailable: true,
      description: 'Créer et gérer des notes vocales',
    ),

    AppFeature(
      name: 'Chat Vocal',
      icon: Icons.chat,
      route: VocalChatScreen.route,
      requiresInternet: true,
      requiresAuth: false,
      isAvailable: true,
      description: 'Discuter avec un assistant vocal',
  ),

  AppFeature(
      name: 'Calculette',
      icon: Icons.calculate,
      route: CalculatorView.route,
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: true,
      description: 'Calculette pour dyscalculique.',
    ),

    AppFeature(
      name: 'Paiement Google Pay ou avec de la monnaie',
      icon: Icons.money,
      route: MoneyManagerView.route,
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: true,
      description: 'Paiement avec Google Pay ou avec de la monnaie.',
    ),

    AppFeature(
      name: 'Aide Gauche / Droite',
      icon: Icons.accessibility_new,
      route: RealTimeYoloScreen.route,
      requiresInternet: false,
      requiresAuth: false,
      isAvailable: true,
      description: 'Aide à la latéralisation via la caméra.',
    ),

    AppFeature(
      name: 'Personnalisation du profil',
      icon: Icons.person,
      route: ProfileScreen.route,
      requiresInternet: false,
      requiresAuth: true,
      isAvailable: true,
      description: 'Personnalisez votre profil',
    ),

   //ajout bouton confidential document
    AppFeature(name: 'Document confidentiel',
        icon: Icons.file_download,
        route: ConfidentialDocumentScreen.route,
        requiresInternet : false,
      requiresAuth: false,
      isAvailable: true,
      description: 'Stocker et visualiser des photos de vos docuemnt confidentiel (carte ID, permis, ...)',
     ),

    AppFeature(
      name: 'Lecteur Web',
      icon: Icons.chrome_reader_mode,
      route: WebReaderScreen.route,
      requiresInternet: true,
      requiresAuth: false,
      isAvailable: true,
      description: 'Accès aux sites gouvernementaux et lecture des informations par synthèse vocale.',
    ),

    AppFeature(name: "Scanner de ticket de caisse",
      icon: Icons.document_scanner,
      route: ReceiptPage.route,
      requiresInternet: true,
      requiresAuth: true,
      isAvailable: true,
      description: "Scan de ticket de caisse"
    ),

    AppFeature(
        name: "Forum",
        icon: Icons.chat,
        route: ForumScreen.route,
        requiresAuth: false,
        requiresInternet: true,
        isAvailable: true,
        description: 'Espace de discussion pour échanger des messages avec les utilisateurs.',
    )
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

  Widget _buildFeaturesGrid(
    BuildContext context,
    HomeViewModel viewModel,
    List<AppFeature> features,
  ) {
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
          onTap: () =>
              _handleFeatureTap(context, viewModel, feature, isAccessible),
        );
      },
    );
  }

  Widget _buildRequirement({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: color)),
          ),
        ],
      ),
    );
  }

  void _handleFeatureTap(
    BuildContext context,
    HomeViewModel viewModel,
    AppFeature feature,
    bool isAccessible,
  ) {
    if (isAccessible) {
      Navigator.pushNamed(context, feature.route);
    } else {
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
          side: BorderSide(color: context.colorScheme.outline, width: 1.0),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Compris'),
            ),
          ),
        ],
      ),
    );
  }
}