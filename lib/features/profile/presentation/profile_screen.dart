import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const String route = '/profile';
  const ProfileScreen({super.key});

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
              backgroundImage: AssetImage('assets/avatar_placeholder.png'),
            ),
            const SizedBox(height: 12),

            // Nom complet
            const Text(
              'Coleen Conte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Infos
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Nom'),
                    subtitle: Text('Coleen'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Prénom'),
                    subtitle: Text('Conte'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text('xxx@mail.com'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Téléphone'),
                    subtitle: Text('06 xx xx xx xx'),
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
