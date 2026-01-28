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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 80),
          const SizedBox(height: 16),
          const Text(
            "Complétez votre profil",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final state = context.read<ProfileCubit>().state;
              UserProfileModel? profile;

              if (state is ProfileLoaded) {
                profile = state.profile;
              } else {
                // creation de profil vide si aucun profil existant
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

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => getIt<ProfileEditCubit>(),
                      child: ProfileEditScreen(profile: profile!), // profil en pré remplissage
                    ),
                  ),
                );
              }
            },
            child: const Text("Créer mon profil"),
          ),
        ],
      ),
    );
  }
}
