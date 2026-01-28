import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/entities/map_camera_command.dart';

class MapWidget extends StatefulWidget {
  final GeoPosition position;
  final GeoPosition? destination;
  final bool isAutoFollowing;

  final VoidCallback onRecenter;
  final VoidCallback onMapDragged;

  final Stream<MapCameraCommand> cameraStream;

  final double _initZoom = 18.0;
  final double _minZoom = 1.0;
  final double _maxZoom = 20.0;

  const MapWidget({
    super.key,
    required this.position,
    this.destination,
    required this.isAutoFollowing,
    required this.onRecenter,
    required this.onMapDragged,
    required this.cameraStream,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  StreamSubscription<MapCameraCommand>? _cameraSubscription;

  void setupCameraListener(Stream<MapCameraCommand> stream) {
    _cameraSubscription?.cancel();
    _cameraSubscription = stream.listen((command) {
      _animatedMapMove(
        LatLng(command.position.latitude, command.position.longitude),
        command.zoom ?? _mapController.camera.zoom,
      );
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );

    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        destZoom,
      );
    });

    controller.forward().then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(
              widget.position.latitude,
              widget.position.longitude,
            ),
            initialZoom: widget._initZoom,
            minZoom: widget._minZoom,
            maxZoom: widget._maxZoom,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) widget.onMapDragged();
            },
          ),
          children: [
            //Background map
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              minZoom: widget._minZoom,
              maxZoom: widget._maxZoom,
            ),

            //Trajectory dot
            // PolylineLayer(
            //   polylines: [
            //     Polyline(points: [], color: Colors.blue, strokeWidth: 4.0),
            //   ],
            // ),

            //Fixed points
            MarkerLayer(
              markers: [
                if (widget.destination != null)
                  Marker(
                    point: LatLng(
                      widget.destination!.latitude,
                      widget.destination!.longitude,
                    ),
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
              ],
            ),

            //User location
            CurrentLocationLayer(
              alignPositionOnUpdate: AlignOnUpdate.never,
              alignDirectionOnUpdate: AlignOnUpdate.never,
              style: LocationMarkerStyle(
                marker: DefaultLocationMarker(color: Colors.blue),
                markerSize: const Size.square(20),
                accuracyCircleColor: const Color(0x182196F3),
                showHeadingSector: true,
                headingSectorRadius: 60,
                headingSectorColor: const Color(0xCC2196F3),
              ),
            ),
          ],
        ),

        Positioned(
          bottom: 16,
          right: 72,
          child: FloatingActionButton(
            onPressed: widget.onRecenter,
            backgroundColor: widget.isAutoFollowing
                ? Colors.blue
                : Colors.white,
            child: Icon(
              widget.isAutoFollowing ? Icons.gps_fixed : Icons.gps_not_fixed,
              color: widget.isAutoFollowing ? Colors.white : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setupCameraListener(widget.cameraStream);
  }
}
