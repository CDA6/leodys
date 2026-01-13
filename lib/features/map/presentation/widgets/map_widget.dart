import 'package:Leodys/features/map/domain/entities/geo_position.dart';
import 'package:flutter/material.dart';

class MapWidget extends StatelessWidget {
  final GeoPosition position;

  const MapWidget({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Text("A beautiful map");
  }
}
