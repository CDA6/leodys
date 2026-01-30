import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/features/map/domain/entities/geo_path.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/entities/map_camera_command.dart';

class MapWidget extends StatefulWidget {
  final GeoPosition position;
  final GeoPosition? destination;
  final bool isAutoFollowing;

  final VoidCallback onRecenter;
  final VoidCallback onMapDragged;

  final Stream<MapCameraCommand> cameraStream;
  final Stream<GeoPosition> currentPositionStream;
  final Stream<GeoPosition?> markerStream;
  final Stream<bool?> followStatusStream;
  final Stream<GeoPath?> pathStream;

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
    required this.currentPositionStream,
    required this.markerStream,
    required this.followStatusStream,
    required this.pathStream,
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
            _buildBackgroundLayer(),
            _buildPolylineLayer(),
            _buildMarkerLayer(),
            _buildUserLocationLayer(),
          ],
        ),

        _buildCenterOnUserButton(),
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

  TileLayer _buildBackgroundLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      minZoom: widget._minZoom,
      maxZoom: widget._maxZoom,
    );
  }

  Widget _buildPolylineLayer() {
    return StreamBuilder<GeoPath?>(
      stream: widget.pathStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return PolylineLayer(
          polylines: [
            Polyline(
              points: snapshot.data!.points.map((p) => p.toLatLng()).toList(),
              color: Colors.blueAccent.withOpacity(0.8),
              strokeWidth: 6.0,
              borderColor: Colors.white,
              borderStrokeWidth: 2.0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarkerLayer() {
    return StreamBuilder<GeoPosition?>(
      stream: widget.markerStream,
      builder: (context, snapshot) {
        final pos = snapshot.data;
        if (pos == null) return const SizedBox.shrink();

        return MarkerLayer(
          markers: [
            Marker(
              point: LatLng(pos.latitude, pos.longitude),
              width: 50,
              height: 50,
              child: Icon(Icons.location_on, color: Colors.red),
            ),
          ],
        );
      },
    );
  }

  Marker _buildDestinationMarker() {
    return Marker(
      point: LatLng(
        widget.destination!.latitude,
        widget.destination!.longitude,
      ),
      width: 50,
      height: 50,
      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
    );
  }

  CurrentLocationLayer _buildUserLocationLayer() {
    return CurrentLocationLayer(
      positionStream: widget.currentPositionStream.map(
        (geoPos) => LocationMarkerPosition(
          latitude: geoPos.latitude,
          longitude: geoPos.longitude,
          accuracy: geoPos.accuracy,
        ),
      ),

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
    );
  }

  Positioned _buildCenterOnUserButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: StreamBuilder<bool?>(
        stream: widget.followStatusStream,
        initialData: widget.isAutoFollowing,
        builder: (context, snapshot) {
          final isFollowing = snapshot.data ?? false;

          return FloatingActionButton(
            onPressed: widget.onRecenter,
            backgroundColor: isFollowing
                ? context.colorScheme.primary
                : context.colorScheme.secondary,
            child: Icon(
              isFollowing ? Icons.gps_fixed : Icons.gps_not_fixed,
              color: isFollowing
                  ? context.colorScheme.onPrimary
                  : context.colorScheme.onSecondary,
            ),
          );
        },
      ),
    );
  }
}
