import 'package:leodys/features/map/domain/entities/geo_position.dart';
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
      appBar: AppBar(title: const Text("Navigation Piéton")),
      body: StreamBuilder<GeoPosition>(
        initialData: widget.viewModel.currentPosition,
        stream: widget.viewModel.positionStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MapWidget(position: snapshot.data!);
          }

          if (snapshot.hasError) {
            final error = snapshot.error.toString();

            //PostFrameCallback to display Popup without breaking the build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showGpsDialog(context, error);
              }
            });

            return const Center(
              child: Icon(Icons.location_off, size: 80, color: Colors.grey),
            );
          }

          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Recherche de position..."),
              ],
            ),
          );
        },
      ),
    );
  }
}
