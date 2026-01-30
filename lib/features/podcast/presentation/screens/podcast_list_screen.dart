import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/podcast.dart';
import '../../injection_container.dart' as di;
import '../viewmodels/audio_player_viewmodel.dart';
import '../viewmodels/podcast_list_viewmodel.dart';
import '../widgets/mini_player.dart';
import '../widgets/podcast_card.dart';
import 'episode_list_screen.dart';


class PodcastListScreen extends StatelessWidget {
  static const route = '/podcast-list';

  final String genre;

  const PodcastListScreen({
    super.key,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<PodcastListViewModel>(param1: genre),
        ),
        ChangeNotifierProvider.value(
          value: di.sl<AudioPlayerViewModel>(),
        ),
      ],
      child: _PodcastListScreenContent(genre: genre),
    );
  }
}

class _PodcastListScreenContent extends StatelessWidget {
  final String genre;

  const _PodcastListScreenContent({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(genre)),
      body: Consumer<PodcastListViewModel>(
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

          if (viewModel.podcasts.isEmpty) {
            return const Center(
              child: Text('Aucun podcast trouvé.'),
            );
          }

          return _buildList(context, viewModel.podcasts);
        },
      ),
      bottomSheet: const MiniPlayer(),
    );
  }

  Widget _buildList(BuildContext context, List<Podcast> podcasts) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 120,
        top: 10,
        left: 16,
        right: 16,
      ),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return PodcastCard(
          podcast: podcast,
          onTap: () => _navigateToEpisodes(context, podcast),
        );
      },
    );
  }

  void _navigateToEpisodes(BuildContext context, Podcast podcast) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EpisodeListScreen(podcast: podcast),
      ),
    );
  }
}
