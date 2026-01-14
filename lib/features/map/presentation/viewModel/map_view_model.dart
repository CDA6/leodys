import 'dart:async';

import 'package:Leodys/features/map/domain/entities/geo_position.dart';
import 'package:Leodys/features/map/domain/useCases/watch_user_location_usecase.dart';
import 'package:Leodys/utils/app_logger.dart';

class MapViewModel {
  final WatchUserLocationUseCase watchUserLocation;
  Stream<GeoPosition> get positionStream => watchUserLocation();

  GeoPosition? currentPosition;

  MapViewModel(this.watchUserLocation);

  void handleLeaving() {
    AppLogger().info("Leaving map page");
  }

  void handleLanding() {
    AppLogger().info("Landing on map page");
  }
}
