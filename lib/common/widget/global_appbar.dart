import 'package:flutter/material.dart';
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
          title: Text(title),
          actions: [
            if (isAuthenticated) ...[
              IconButton(
                icon: const Icon(Icons.logout),
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
                icon: const Icon(Icons.login, color: Colors.black),
                label: const Text(
                  'Se connecter',
                  style: TextStyle(color: Colors.black),
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
                icon: const Icon(Icons.person_add, color: Colors.black),
                label: const Text(
                  's\'inscrire',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
