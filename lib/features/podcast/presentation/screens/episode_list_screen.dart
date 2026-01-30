import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/podcast.dart';
import '../../injection_container.dart' as di;
import '../viewmodels/audio_player_viewmodel.dart';
import '../viewmodels/episode_list_viewmodel.dart';
import '../widgets/episode_list_item.dart';
import '../widgets/mini_player.dart';


class EpisodeListScreen extends StatelessWidget {
  static const route = '/episode-list';

  final Podcast podcast;

  const EpisodeListScreen({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<EpisodeListViewModel>(param1: podcast),
        ),
        ChangeNotifierProvider.value(
          value: di.sl<AudioPlayerViewModel>(),
        ),
      ],
      child: _EpisodeListScreenContent(podcast: podcast),
    );
  }
}

class _EpisodeListScreenContent extends StatelessWidget {
  final Podcast podcast;

  const _EpisodeListScreenContent({required this.podcast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(podcast.title)),
      body: Consumer<EpisodeListViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement du flux',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadEpisodes,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.episodes.isEmpty) {
            return const Center(
              child: Text('Aucun épisode trouvé.'),
            );
          }

          return _buildList(context, viewModel);
        },
      ),
      bottomSheet: const MiniPlayer(),
    );
  }

  Widget _buildList(BuildContext context, EpisodeListViewModel viewModel) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: viewModel.episodes.length,
      separatorBuilder: (_, i) => const Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
      ),
      itemBuilder: (context, index) {
        final episode = viewModel.episodes[index];
        return EpisodeListItem(
          episode: episode,
          imageUrl: viewModel.getImageUrl(episode),
          onPlay: episode.isPlayable
              ? () => _playEpisode(context, episode, viewModel)
              : null,
        );
      },
    );
  }

  void _playEpisode(
    BuildContext context,
    Episode episode,
    EpisodeListViewModel viewModel,
  ) {
    final audioVM = context.read<AudioPlayerViewModel>();
    audioVM.playEpisode(
      url: episode.mp3Url!,
      title: episode.title,
      imageUrl: viewModel.getImageUrl(episode),
    );
  }
}
