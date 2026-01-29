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

    return const AssetImage('assets/images/avatar_placeholder.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // avatar
            CircleAvatar(
              radius: 52,
              backgroundColor: colorScheme.surfaceContainerHighest,
              backgroundImage: getProfileImage(profile),
            ),
            const SizedBox(height: 12),

            // nom complet du user
            Text(
              '${profile.firstName} ${profile.lastName}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // infos du profil
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: colorScheme.primary),
                    title: Text('Nom', style: textTheme.bodyMedium),
                    subtitle: Text(profile.lastName, style: textTheme.bodySmall),
                  ),
                  Divider(height: 1, color: colorScheme.outline),
                  ListTile(
                    leading: Icon(Icons.person_outline, color: colorScheme.primary),
                    title: Text('Prénom', style: textTheme.bodyMedium),
                    subtitle: Text(profile.firstName, style: textTheme.bodySmall),
                  ),
                  Divider(height: 1, color: colorScheme.outline),
                  ListTile(
                    leading: Icon(Icons.email, color: colorScheme.primary),
                    title: Text('Email', style: textTheme.bodyMedium),
                    subtitle: Text(profile.email, style: textTheme.bodySmall),
                  ),
                  Divider(height: 1, color: colorScheme.outline),
                  ListTile(
                    leading: Icon(Icons.phone, color: colorScheme.primary),
                    title: Text('Téléphone', style: textTheme.bodyMedium),
                    subtitle: Text(profile.phone, style: textTheme.bodySmall),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bouton modifier
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
                  ).then((_) {
                    if (context.mounted) {
                      context.read<ProfileCubit>().loadProfile();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
