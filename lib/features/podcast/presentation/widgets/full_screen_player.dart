import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/audio_player_viewmodel.dart';

class FullScreenPlayer extends StatelessWidget {
  const FullScreenPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lecteur',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Consumer<AudioPlayerViewModel>(
        builder: (context, audioVM, _) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                _buildCoverImage(audioVM),
                const SizedBox(height: 40),
                _buildTitle(audioVM),
                const Spacer(),
                _buildProgressSlider(audioVM),
                _buildControls(audioVM),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoverImage(AudioPlayerViewModel audioVM) {
    final imageUrl = audioVM.audioState.currentImageUrl;

    return Container(
      height: 280,
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        image: imageUrl != null && imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
        color: Colors.grey.shade100,
      ),
      child: imageUrl == null || imageUrl.isEmpty
          ? const Icon(Icons.music_note, size: 80, color: Colors.grey)
          : null,
    );
  }

  Widget _buildTitle(AudioPlayerViewModel audioVM) {
    return Text(
      audioVM.audioState.currentTitle ?? '',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressSlider(AudioPlayerViewModel audioVM) {
    final position = audioVM.audioState.position;
    final duration = audioVM.audioState.duration;

    return Column(
      children: [
        Slider(
          value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
          max: duration.inSeconds.toDouble().clamp(1, double.infinity),
          activeColor: Colors.blueGrey,
          inactiveColor: Colors.blueGrey.shade100,
          onChanged: (value) {
            audioVM.seek(Duration(seconds: value.toInt()));
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(audioVM.audioState.formattedPosition),
            Text(audioVM.audioState.formattedDuration),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(AudioPlayerViewModel audioVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10_rounded, size: 36),
          onPressed: audioVM.skipBackward,
        ),
        const SizedBox(width: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueGrey,
          ),
          child: IconButton(
            icon: Icon(
              audioVM.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 48,
              color: Colors.white,
            ),
            onPressed: audioVM.pauseResume,
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.forward_30_rounded, size: 36),
          onPressed: audioVM.skipForward,
        ),
      ],
    );
  }
}
