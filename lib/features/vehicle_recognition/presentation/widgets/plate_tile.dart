import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/models/plate_scan.dart';

class PlateTile extends StatelessWidget {
  final PlateScan plateScan;
  final VoidCallback onRead;
  final VoidCallback onDelete;

  const PlateTile({super.key,
    required this.plateScan,
    required this.onRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(plateScan.plate),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: onRead,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
