import 'package:flutter/material.dart';
import '../../domain/entities/podcast.dart';

// Carte affichant un podcast dans une liste.
class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final VoidCallback onTap;

  const PodcastCard({
    super.key,
    required this.podcast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildLeadingImage(),
        title: Text(
          podcast.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLeadingImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: podcast.imageUrl.isNotEmpty
            ? Image.network(
                podcast.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => const Icon(
                  Icons.mic,
                  color: Colors.grey,
                ),
              )
            : const Icon(Icons.mic, color: Colors.grey),
      ),
    );
  }
}
