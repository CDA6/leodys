import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/audio_player_viewmodel.dart';
import 'full_screen_player.dart';

// Lecteur audio minimaliste affiché en bas de l'écran.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerViewModel>(
      builder: (context, audioVM, _) {
        if (!audioVM.hasCurrentEpisode) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _showFullScreenPlayer(context),
          child: Container(
            height: 75,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildImage(audioVM),
                Expanded(child: _buildInfo(audioVM)),
                _buildPlayPauseButton(audioVM),
                const SizedBox(width: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(AudioPlayerViewModel audioVM) {
    final imageUrl = audioVM.audioState.currentImageUrl;

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: 75,
              height: 75,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => Container(
                color: Colors.grey,
                width: 75,
                height: 75,
              ),
            )
          : Container(
              width: 75,
              height: 75,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildInfo(AudioPlayerViewModel audioVM) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            audioVM.audioState.currentTitle ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'En lecture',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton(AudioPlayerViewModel audioVM) {
    return IconButton(
      icon: Icon(
        audioVM.isPlaying ? Icons.pause_circle : Icons.play_circle,
        size: 48,
        color: Colors.blueGrey,
      ),
      onPressed: audioVM.pauseResume,
    );
  }

  void _showFullScreenPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AudioPlayerViewModel>(),
        child: const FullScreenPlayer(),
      ),
    );
  }
}
