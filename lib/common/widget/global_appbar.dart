import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context.dart';
import 'package:leodys/features/authentication/presentation/pages/auth/signin_page.dart';
import 'package:leodys/features/authentication/presentation/pages/auth/register_page.dart';
import 'package:provider/provider.dart';
import '../../features/authentication/domain/services/auth_service.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GlobalAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final isAuthenticated = authService.isAuthenticated;

        return AppBar(
          backgroundColor: context.colorScheme.primaryContainer,
          title: Text(
            title,
            style: TextStyle(color: context.colorScheme.onPrimaryContainer),
          ),
          actions: [
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
        );
      },
    );
  }
}
