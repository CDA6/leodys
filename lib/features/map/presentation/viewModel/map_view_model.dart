import 'dart:async';

import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/useCases/watch_user_location_usecase.dart';
import 'package:leodys/common/utils/app_logger.dart';

class MapViewModel {
  final WatchUserLocationUseCase watchUserLocation;
  Stream<GeoPosition> get positionStream => watchUserLocation().map((pos) {
    _lastKnownPosition = pos;
    return pos;
  });

  GeoPosition? _lastKnownPosition;
  GeoPosition? get currentPosition => _lastKnownPosition;

  MapViewModel(this.watchUserLocation);

  void handleLeaving() {
    AppLogger().info("Leaving map page");
  }

  void handleLanding() {
    AppLogger().info("Landing on map page");
  }
}
