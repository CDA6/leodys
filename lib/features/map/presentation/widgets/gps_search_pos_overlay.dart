import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';

class GpsSearchPosOverlay extends StatelessWidget {
  final Stream<GeoPosition> positionStream;

  const GpsSearchPosOverlay({super.key, required this.positionStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GeoPosition>(
      stream: positionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData || snapshot.hasError) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Recherche position...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
