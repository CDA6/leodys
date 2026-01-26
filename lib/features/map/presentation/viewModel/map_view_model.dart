import 'dart:async';

import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/useCases/watch_user_location_usecase.dart';
import 'package:leodys/common/utils/app_logger.dart';

class MapViewModel {
  final WatchUserLocationUseCase watchUserLocation;

  GeoPosition? _lastKnownPosition;
  GeoPosition? get currentPosition => _lastKnownPosition;

  StreamSubscription<GeoPosition>? _locationSubscription;

  final StreamController<GeoPosition> _positionController =
      StreamController<GeoPosition>.broadcast();

  Stream<GeoPosition> get positionStream => _positionController.stream;

  MapViewModel(this.watchUserLocation);

  void handleLeaving() {
    AppLogger().info("Leaving map page, stop GPS listener");
    stopGpsStreamListener();
  }

  void handleLanding() {
    AppLogger().info("Landing on map page, start GPS listener");
    startGpsStreamListener();
  }

  void dispose() {
    AppLogger().info(
      "Abrupt closing of the application : closing the GPS stream controller",
    );
    _positionController.close();
  }

  void stopGpsStreamListener() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void startGpsStreamListener() {
    _locationSubscription?.cancel();
    _locationSubscription = watchUserLocation().listen((pos) {
      _lastKnownPosition = pos;
      _positionController.add(pos); // Transmission to the widget
    }, onError: (error) => _positionController.addError(error));
  }
}
