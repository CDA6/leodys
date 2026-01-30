import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/failures/gps_failures.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:leodys/features/map/presentation/widgets/gps_dialog.dart';
import 'package:leodys/features/map/presentation/widgets/map_app_bar.dart';
import 'package:leodys/features/map/presentation/widgets/map_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/gps_search_pos_overlay.dart';

class MapScreen extends StatefulWidget {
  final MapViewModel viewModel;
  static const String route = '/map';

  const MapScreen({super.key, required this.viewModel});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    widget.viewModel.positionStream.listen(
      (_) {},
      onError: (error) {
        if (error is GpsFailure) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showGpsDialog(context, error);
            }
          });
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.viewModel.handleLanding();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.viewModel.handleLeaving();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.viewModel.handleLeaving();
    } else if (state == AppLifecycleState.resumed) {
      widget.viewModel.handleLanding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MapAppBar(
        onSearch: (query) => widget.viewModel.onSearch(query),
        onLocationSelected: (loc) => widget.viewModel.moveToLocation(loc),
      ),
      body: Stack(
        children: [
          MapWidget(
            position:
                widget.viewModel.currentPosition ??
                const GeoPosition(latitude: 0, longitude: 0),
            cameraStream: widget.viewModel.cameraCommandStream,
            currentPositionStream: widget.viewModel.positionStream,
            markerStream: widget.viewModel.markerStream,
            followStatusStream: widget.viewModel.followStatusStream,

            isAutoFollowing: widget.viewModel.isFollowingUser,

            onRecenter: () => widget.viewModel.resumeAutoFollowing(),
            onMapDragged: () => widget.viewModel.disableAutoFollowing(),
          ),

          GpsSearchPosOverlay(positionStream: widget.viewModel.positionStream),
        ],
      ),
    );
  }
}
