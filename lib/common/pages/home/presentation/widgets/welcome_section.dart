import 'package:flutter/material.dart';
import 'package:leodys/common/pages/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:leodys/common/theme/theme_context.dart';

class WelcomeSection extends StatelessWidget {

  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewmodel, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue',
                style: TextStyle(
                  color: context.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewmodel.isAuthenticated
                    ? 'Toutes vos fonctionnalités à portée de main !'
                    : 'Connectez-vous pour accéder à toutes les fonctionnalités',
                style: TextStyle(
                  color: context.colorScheme.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}