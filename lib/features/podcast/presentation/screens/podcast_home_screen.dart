import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../injection_container.dart' as di;
import '../viewmodels/audio_player_viewmodel.dart';
import '../viewmodels/podcast_home_viewmodel.dart';
import '../widgets/mini_player.dart';
import '../widgets/radio_logo_card.dart';
import 'podcast_list_screen.dart';

// Affiche les catégories de radios (France Inter, France Culture, Mes Ajouts).
class PodcastHomeScreen extends StatelessWidget {
  static const route = '/podcast-home';

  const PodcastHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<PodcastHomeViewModel>(),
        ),
        ChangeNotifierProvider.value(
          value: di.sl<AudioPlayerViewModel>(),
        ),
      ],
      child: const _PodcastHomeScreenContent(),
    );
  }
}

class _PodcastHomeScreenContent extends StatelessWidget {
  const _PodcastHomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Radios')),
      body: Consumer<PodcastHomeViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadPodcasts,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return _buildContent(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
      bottomSheet: const MiniPlayer(),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            RadioLogoCard(
              logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/France_Inter_logo_2024.svg/240px-France_Inter_logo_2024.svg.png',
              label: 'France Inter',
              borderColor: Colors.red.shade100,
              onTap: () => _navigateToList(context, 'France Inter'),
            ),
            const SizedBox(height: 30),
            RadioLogoCard(
              logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/France_Culture_logo_2024.svg/240px-France_Culture_logo_2024.svg.png',
              label: 'France Culture',
              borderColor: Colors.purple.shade100,
              onTap: () => _navigateToList(context, 'France Culture'),
            ),
            const SizedBox(height: 30),
            RadioLogoCard(
              logoUrl: '',
              label: 'Mes Ajouts',
              isCustom: true,
              borderColor: Colors.orange.shade100,
              onTap: () => _navigateToList(context, 'Autre'),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _navigateToList(BuildContext context, String genre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PodcastListScreen(genre: genre),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un Podcast'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL RSS'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary, // Couleur du texte
            ),
            onPressed: () async {
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                final viewModel = context.read<PodcastHomeViewModel>();
                final success = await viewModel.addPodcast(
                  title: titleController.text,
                  rssUrl: urlController.text,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (!success && viewModel.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(viewModel.errorMessage!)),
                    );
                  }
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
