import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioControls extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const AudioControls({
    super.key,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        ElevatedButton.icon(
          onPressed: onPlay,
          icon: Icon(Icons.play_arrow),
          label: Text('Lire'),
        ),

        const SizedBox(height: 16,),

        ElevatedButton.icon(
            onPressed: onPause,
            icon: Icon(Icons.pause),
            label: Text('Pause'),
        ),

        const SizedBox(height: 16,),

        ElevatedButton.icon(
            onPressed: onResume,
            icon: Icon(Icons.play_circle),
            label: Text('Reprendre')
        ),

        const SizedBox(height: 16,),

        ElevatedButton.icon(
            onPressed: onStop,
            icon: Icon(Icons.stop),
            label: Text('Arrêter'),
        ),

      ],
    );
  }
}
