import 'package:leodys/common/utils/app_logger.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/failures/gps_failures.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';
import 'package:leodys/features/map/presentation/widgets/gps_dialog.dart';
import 'package:leodys/features/map/presentation/widgets/map_widget.dart';
import 'package:flutter/material.dart';

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
    widget.viewModel.handleLanding();

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
    return Scaffold(appBar: _buildAppbar(), body: _buildMap());
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: const Text("Navigation Piéton"),
      actions: [
        SearchAnchor(
          builder: (context, controller) {
            return IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                AppLogger().info("Opening search location");
                controller.openView();
              },
            );
          },

          suggestionsBuilder: (context, controller) async {
            if (controller.text.length < 3) {
              return [const ListTile(title: Text("Trois caractères minimum"))];
            }

            final results = await widget.viewModel.onSearch(controller.text);
            if (results.isEmpty) {
              return [const ListTile(title: Text("Aucun résultat trouvé"))];
            }

            return results.map(
              (res) => ListTile(
                leading: const Icon(Icons.location_on, color: Colors.blue),
                title: Text(res.name),
                onTap: () {
                  AppLogger().info(
                    "Closing search location, result choice : ${res.position.toString()}",
                  );
                  controller.closeView(res.name);
                  widget.viewModel.moveToLocation(res);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  MapWidget _buildMap() {
    return MapWidget(
      position:
          widget.viewModel.currentPosition ??
          const GeoPosition(latitude: 0, longitude: 0),
      cameraStream: widget.viewModel.cameraCommandStream,
      currentPositionStream: widget.viewModel.positionStream,
      markerStream: widget.viewModel.markerStream,

      isAutoFollowing: widget.viewModel.isFollowingUser,

      onRecenter: () {
        setState(() {
          widget.viewModel.resumeAutoFollowing();
        });
      },

      onMapDragged: () {
        if (widget.viewModel.isFollowingUser) {
          setState(() {
            widget.viewModel.disableAutoFollowing();
          });
        }
      },
    );
  }
}
