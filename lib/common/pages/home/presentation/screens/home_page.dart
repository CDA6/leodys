import 'package:flutter/material.dart';
import 'package:leodys/common/widget/connection_warning.dart';
import 'package:leodys/common/widget/global_appbar.dart';
import 'package:leodys/features/accessibility/presentation/viewmodels/settings_viewmodel.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/feature_list.dart';

/// Page d'accueil de l'application.
///
/// Affiche :
/// - Un en-tête de bienvenue
/// - Un avertissement d'absence de connexion
/// - La liste des fonctionnalités disponibles (via le widget FeatureList)
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        appBar: const GlobalAppBar(title: 'Accueil'),
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isCheckingConnectivity) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête de bienvenue
                    _buildWelcomeSection(context, viewModel),
                    const SizedBox(height: 24),

                    // Avertissement si pas de connexion
                    if (!viewModel.isConnected) ...[
                      ConnectionWarning('Pas de connexion Internet. Certaines fonctionnalités sont limitées.'),
                      const SizedBox(height: 16),
                    ],

                    // Liste des fonctionnalités
                    const FeatureList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildWelcomeSection(BuildContext context, HomeViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Utilise les couleurs du thème au lieu de bleu fixe
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.isAuthenticated
                ? 'Toutes vos fonctionnalités à portée de main !'
                : 'Connectez-vous pour accéder à toutes les fonctionnalités',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

}