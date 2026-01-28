import 'package:flutter/material.dart';
import 'package:leodys/features/profile/domain/models/user_profile_model.dart';

class ProfileView extends StatelessWidget {
  final UserProfileModel profile;
  const ProfileView({super.key, required this.profile});

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
              backgroundImage: AssetImage(profile.avatarPath ?? 'assets/images/avatar_placeholder.jpg'),
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
                  Navigator.pushNamed(context, '/edit-profile');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
