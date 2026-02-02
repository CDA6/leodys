import 'package:flutter/material.dart';

class AudioControls extends StatelessWidget {

  // VoidCallback est une fonction qui ne retourne rien
  // Son role sera attribué plus tard en lui donnant une implémentation
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;

  const AudioControls({
    super.key,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // étire les élément à l'interieur de la colone sur toute la largeur disponible
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // Bouton play
        ElevatedButton.icon(
          onPressed: onPlay,
          icon: Icon(Icons.play_arrow),
          label: Text('Lire'),
        ),

        const SizedBox(height: 16,),

        // Bouton pause
        ElevatedButton.icon(
            onPressed: onPause,
            icon: Icon(Icons.pause),
            label: Text('Pause'),
        ),

        const SizedBox(height: 16,),

        // Bouton Stop
        ElevatedButton.icon(
            onPressed: onStop,
            icon: Icon(Icons.stop),
            label: Text('Arrêter'),
        ),
      ],
    );
  }
}
