import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';

class MapWidget extends StatefulWidget {
  final GeoPosition position;
  final double _initZoom = 18.0;
  final double _minZoom = 1.0;
  final double _maxZoom = 20.0;

  const MapWidget({super.key, required this.position});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  //Call if position is updated
  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.position != widget.position) {
      _animatedMapMove(
        LatLng(widget.position.latitude, widget.position.longitude),
        _mapController.camera.zoom,
      );
    }
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
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(
          widget.position.latitude,
          widget.position.longitude,
        ),
        initialZoom: widget._initZoom,
        minZoom: widget._minZoom,
        maxZoom: widget._maxZoom,
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
            // Marker(
            //   point: LatLng(
            //     widget.position.latitude,
            //     widget.position.longitude,
            //   ),
            //   child: const Icon(Icons.my_location, color: Colors.blue),
            // ),
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
    );
  }
}
