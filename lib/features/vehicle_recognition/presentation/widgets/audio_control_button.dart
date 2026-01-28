import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioControlButton extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onStop;

  const AudioControlButton({
    super.key,
    required this.onPlay,
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
            onPressed: onStop,
            icon: Icon(Icons.stop),
            label: Text('Arrêter'),
        ),

      ],
    );
  }
}
