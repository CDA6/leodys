import 'package:flutter/material.dart';
import '../../domain/models/plate_scan.dart';

class PlateTile extends StatelessWidget {
  final PlateScan scan;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final VoidCallback onDelete;

  const PlateTile({
    super.key,
    required this.scan,
    required this.isPlaying,
    required this.onPlay,
    required this.onStop,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(scan.plate),
      subtitle: Text(scan.vehicleLabel),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: onPlay,
          ),
          IconButton(onPressed: onStop, icon: Icon(Icons.stop)),
          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        ],
      ),
    );
  }
}
