import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:leodys/common/widget/connection_warning.dart';
import 'package:leodys/common/widget/global_appbar.dart';
import 'package:leodys/common/pages/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:leodys/common/pages/home/presentation/widgets/welcome_section.dart';
import 'package:leodys/common/pages/home/presentation/widgets/feature_list.dart';

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
                    WelcomeSection(),
                    const SizedBox(height: 24),

                    // Avertissement si pas de connexion
                    if (!viewModel.isConnected) ...[
                      ConnectionWarning(message: 'Pas de connexion Internet. Certaines fonctionnalités sont limitées.'),
                      const SizedBox(height: 16),
                    ],

                    // Liste des fonctionnalités
                    const FeatureList(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}