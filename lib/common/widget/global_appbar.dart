import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:leodys/common/theme/theme_context_extension.dart';

import 'package:leodys/features/authentication/presentation/pages/auth/signin_page.dart';
import 'package:leodys/features/authentication/presentation/pages/auth/register_page.dart';
import '../../features/authentication/domain/services/auth_service.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  /// Actions personnalisées à afficher AVANT les actions d'authentification
  final List<Widget>? actions;

  /// Si true, affiche les actions d'authentification par défaut
  final bool showAuthActions;

  const GlobalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showAuthActions = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Si des actions complètement personnalisées sont fournies
        if (actions != null) {
          return AppBar(
            backgroundColor: context.colorScheme.primaryContainer,
            title: Text(
              title,
              style: TextStyle(color: context.colorScheme.onPrimaryContainer),
            ),
            iconTheme: IconThemeData(
              color: context.colorScheme.onPrimaryContainer
            ),
            actions: actions,
          );
        }

        // Sinon, construire les actions avec authentification
        final isAuthenticated = authService.isAuthenticated;

        return AppBar(
          backgroundColor: context.colorScheme.primaryContainer,
          title: Text(
            title,
            style: TextStyle(color: context.colorScheme.onPrimaryContainer),
          ),
          iconTheme: IconThemeData(
              color: context.colorScheme.onPrimaryContainer
          ),
          actions: [
            // Actions personnalisées
            if (actions != null) ...actions!,

            // Actions d'authentification par défaut
            if (showAuthActions) ...[
              if (isAuthenticated) ...[
                IconButton(
                  icon: Icon(Icons.logout, color: context.colorScheme.onPrimaryContainer),
                  tooltip: 'Déconnexion',
                  onPressed: () async {
                    await authService.signOut();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vous êtes déconnecté'),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ] else ...[
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SigninPage(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  icon: Icon(Icons.login, color: context.colorScheme.onPrimaryContainer),
                  label: Text(
                    'Se connecter',
                    style: TextStyle(color: context.colorScheme.onPrimaryContainer),
                  ),
                ),

                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  icon: Icon(Icons.person_add, color: context.colorScheme.onPrimaryContainer),
                  label: Text(
                    's\'inscrire',
                    style: TextStyle(color: context.colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}