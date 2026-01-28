import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leodys/features/profile/domain/models/user_profile_model.dart';
import 'package:leodys/features/profile/presentation/screens/profile_edit_screen.dart';

import '../../../cards/providers.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_edit_cubit.dart';

class ProfileView extends StatelessWidget {
  final UserProfileModel profile;
  const ProfileView({super.key, required this.profile});

  // permet de gérer les exceptions si l'image du profil a été supprimée localement par ex
  ImageProvider<Object> getProfileImage(UserProfileModel profile) {
    if (profile.avatarPath != null && profile.avatarPath!.isNotEmpty) {
      final file = File(profile.avatarPath!);
      if (file.existsSync() && file.lengthSync() > 0) {
        return FileImage(file);
      }
    }

    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return NetworkImage(profile.avatarUrl!);
    }

    // fallback si pas d'image
    return const AssetImage('assets/images/avatar_placeholder.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: getProfileImage(profile)
            ),
            const SizedBox(height: 12),

            // nom complet
            Text(
              '${profile.firstName} ${profile.lastName}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // infos du profil
            Card(
              child: Column(
                children:  [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Nom'),
                    subtitle: Text(profile.lastName),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Prénom'),
                    subtitle: Text(profile.firstName),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text(profile.email),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Téléphone'),
                    subtitle: Text(profile.phone),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // bouton de modification
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Modifier le profil'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => getIt<ProfileEditCubit>(),
                        child: ProfileEditScreen(profile: profile),
                      ),
                    ),
                  );

                  if (context.mounted) {
                    context.read<ProfileCubit>().loadProfile();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
