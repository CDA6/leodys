import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leodys/features/profile/domain/models/user_profile_model.dart';
import 'package:leodys/features/profile/presentation/screens/profile_edit_screen.dart';

import '../../../cards/providers.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_edit_cubit.dart';
import '../cubit/profile_state.dart';

class EmptyProfileView extends StatelessWidget {
  const EmptyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Card(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // icone
              Icon(
                Icons.person_outline,
                size: 80,
                color: colorScheme.onSurfaceVariant,
              ),

              const SizedBox(height: 16),

              // titre
              Text(
                "Complétez votre profil",
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // description
              Text(
                "Ajoutez vos informations pour personnaliser votre expérience.",
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // bouton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final state = context.read<ProfileCubit>().state;
                    UserProfileModel profile;

                    if (state is ProfileLoaded) {
                      profile = state.profile;
                    } else {
                      profile = UserProfileModel(
                        userId: '',
                        firstName: '',
                        lastName: '',
                        email: '',
                        phone: '',
                        avatarPath: null,
                        avatarUrl: null,
                        updatedAt: DateTime.now(),
                        syncStatus: 'local',
                      );
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => getIt<ProfileEditCubit>(),
                          child: ProfileEditScreen(profile: profile),
                        ),
                      ),
                    );
                  },
                  child: const Text("Créer mon profil"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
