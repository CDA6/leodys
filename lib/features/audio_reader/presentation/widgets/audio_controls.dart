import 'package:flutter/material.dart';

class AudioControls extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onPause;

  const AudioControls({
    super.key,
    required this.onPlay,
    required this.onPause,
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

      ],
    );
  }
}
