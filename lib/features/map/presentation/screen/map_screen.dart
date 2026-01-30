import 'package:leodys/features/map/domain/entities/geo_path.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/failures/gps_failures.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:leodys/features/map/presentation/widgets/cancel_navigation_button.dart';
import 'package:leodys/features/map/presentation/widgets/gps_dialog.dart';
import 'package:leodys/features/map/presentation/widgets/map_app_bar.dart';
import 'package:leodys/features/map/presentation/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:leodys/features/map/presentation/widgets/navigation_confirm_overlay.dart';

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
        onLocationSelected: (loc) => widget.viewModel.prepareNavigation(loc),
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
            pathStream: widget.viewModel.pathStream,

            isAutoFollowing: widget.viewModel.isFollowingUser,

            onRecenter: () => widget.viewModel.resumeAutoFollowing(),
            onMapDragged: () => widget.viewModel.disableAutoFollowing(),
          ),

          // Cancel path button, visible only if navigation was enabled
          Positioned(
            bottom: 16,
            left: 16,
            child: StreamBuilder<bool>(
              stream: widget.viewModel.isNavigatingStream,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return CancelNavigationButton(
                    onStop: () => _showCancelConfirmation(context),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: StreamBuilder<GeoPath?>(
              stream: widget.viewModel.pendingPathStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox.shrink();
                }

                return NavigationConfirmOverlay(
                  path: snapshot.data!,
                  onConfirm: () =>
                      widget.viewModel.confirmNavigation(snapshot.data!),
                  onCancel: () => widget.viewModel.cancelNavigation(),
                );
              },
            ),
          ),

          GpsSearchPosOverlay(positionStream: widget.viewModel.positionStream),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Arrêter le trajet ?"),
          content: const Text(
            "Voulez-vous vraiment annuler la navigation en cours ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Continuer"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.viewModel.cancelNavigation();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Oui, arrêter"),
            ),
          ],
        );
      },
    );
  }
}
