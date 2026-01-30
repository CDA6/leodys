import 'package:flutter/material.dart';
import '../../domain/entities/episode.dart';

// Élément de liste affichant un épisode de podcast.
class EpisodeListItem extends StatelessWidget {
  final Episode episode;
  final String? imageUrl;
  final VoidCallback? onPlay;

  const EpisodeListItem({
    super.key,
    required this.episode,
    this.imageUrl,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      leading: _buildLeadingImage(),
      title: Text(
        episode.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Durée : ${episode.formattedDuration}',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: _buildPlayButton(),
    );
  }

  Widget _buildLeadingImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => Container(
                color: Colors.grey.shade200,
                width: 50,
                height: 50,
              ),
            )
          : Container(
              color: Colors.grey.shade200,
              width: 50,
              height: 50,
              child: const Icon(Icons.music_note),
            ),
    );
  }

  Widget _buildPlayButton() {
    final isPlayable = episode.isPlayable;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlayable ? Colors.blueGrey.shade50 : Colors.grey.shade200,
      ),
      child: IconButton(
        icon: Icon(
          Icons.play_arrow_rounded,
          color: isPlayable ? Colors.blueGrey : Colors.grey,
        ),
        onPressed: isPlayable ? onPlay : null,
      ),
    );
  }
}
