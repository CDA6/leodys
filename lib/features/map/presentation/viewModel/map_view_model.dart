import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:leodys/features/map/domain/entities/geo_path.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/entities/location_search_result.dart';
import 'package:leodys/features/map/domain/entities/map_camera_command.dart';
import 'package:leodys/features/map/domain/failures/gps_failures.dart';
import 'package:leodys/features/map/domain/useCases/get_path_usecase.dart';
import 'package:leodys/features/map/domain/useCases/search_location_usecase.dart';
import 'package:leodys/features/map/domain/useCases/watch_user_location_usecase.dart';
import 'package:leodys/common/utils/app_logger.dart';

class MapViewModel {
  final SearchLocationUseCase searchAddress;

  // <editor-fold desc="Attributes">

  // <editor-fold desc="General values">
  GeoPosition? _lastKnownPosition;
  GeoPosition? get currentPosition => _lastKnownPosition;

  bool _isAutoFollowingUser = true;
  bool get isFollowingUser => _isAutoFollowingUser;

  final StreamController<bool> _followStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get followStatusStream => _followStatusController.stream;

  final StreamController<MapCameraCommand> _cameraCommandController =
      StreamController<MapCameraCommand>.broadcast();
  Stream<MapCameraCommand> get cameraCommandStream =>
      _cameraCommandController.stream;

  final StreamController<GeoPosition?> _destinationController =
      StreamController.broadcast();
  Stream<GeoPosition?> get markerStream => _destinationController.stream;
  // </editor-fold>

  // <editor-fold desc="GeoLocator">
  final WatchUserLocationUseCase watchUserLocation;

  StreamSubscription<Either<GpsFailure, GeoPosition>>? _locationSubscription;

  final StreamController<GeoPosition> _positionController =
      StreamController<GeoPosition>.broadcast();

  Stream<GeoPosition> get positionStream => _positionController.stream;
  // </editor-fold>

  // <editor-fold desc="Location research">
  List<LocationSearchResult> _searchResults = [];
  List<LocationSearchResult> get searchResults => _searchResults;

  Timer? _searchWaitingTimer;

  LocationSearchResult? _selectedDestination;
  LocationSearchResult? get selectedDestination => _selectedDestination;

  static const double searchRadiusInKm = 5;
  // </editor-fold>

  // <editor-fold desc="Path navigation">
  final GetPathUseCase getWalkingPath;

  final StreamController<GeoPath?> _pathController =
      StreamController<GeoPath?>.broadcast();
  Stream<GeoPath?> get pathStream => _pathController.stream;

  GeoPath? _lastPath;

  final StreamController<GeoPath?> _pendingPathController =
      StreamController<GeoPath?>.broadcast();
  Stream<GeoPath?> get pendingPathStream => _pendingPathController.stream;

  final StreamController<bool> _isNavigatingController =
      StreamController<bool>.broadcast();
  Stream<bool> get isNavigatingStream => _isNavigatingController.stream;

  bool _isNavigating = false;
  // </editor-fold>
  // </editor-fold>

  MapViewModel(this.watchUserLocation, this.searchAddress, this.getWalkingPath);

  // <editor-fold desc="Methods">
  // <editor-fold desc="Lifecycle">
  void handleLeaving() {
    AppLogger().info("Leaving map page, stop GPS listener");
    stopGpsStreamController();
    _searchWaitingTimer?.cancel();
  }

  void handleLanding() {
    AppLogger().info("Landing on map page, start GPS listener");

    final cachedPos = watchUserLocation.getLastKnownPosition();
    if (cachedPos != null) {
      _lastKnownPosition = cachedPos;
      _positionController.add(cachedPos);
      _cameraCommandController.add(
        MapCameraCommand(position: cachedPos, zoom: 18),
      );
    }

    startGpsStreamListener();
  }

  void dispose() {
    stopGpsStreamController();
    _searchWaitingTimer?.cancel();

    _positionController.close();
    _cameraCommandController.close();
    _destinationController.close();
    _followStatusController.close();
    _pathController.close();
    _pendingPathController.close();
    _isNavigatingController.close();
  }
  // </editor-fold>

  // <editor-fold desc="GeoLocator">
  void startGpsStreamListener() {
    _locationSubscription?.cancel();
    _locationSubscription = watchUserLocation().listen((either) {
      either.fold(
        (failure) {
          AppLogger().error("Erreur GPS : ${failure.message}");
          _positionController.addError(failure);
        },
        (pos) {
          _lastKnownPosition = pos;
          _positionController.add(pos);

          if (_isNavigating) {
            updatePathProgress(pos);
          }

          if (_isAutoFollowingUser) {
            _cameraCommandController.add(MapCameraCommand(position: pos));
          }
        },
      );
    });
  }

  void stopGpsStreamController() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
  // </editor-fold>

  // <editor-fold desc="Location research">
  Future<List<LocationSearchResult>> onSearch(String query) async {
    if (query.isEmpty) {
      return [];
    }

    _searchWaitingTimer?.cancel();
    final completer = Completer<List<LocationSearchResult>>();

    _searchWaitingTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        _searchResults = await searchAddress(
          query,
          _lastKnownPosition!,
          searchRadiusInKm,
        );
        completer.complete(_searchResults);
      } catch (e) {
        AppLogger().error(
          "An error occurred while retrieving location data: $e",
        );
        completer.complete([]);
      }
    });

    return completer.future;
  }
  // </editor-fold>

  void moveToLocation(LocationSearchResult destination) {
    disableAutoFollowing();
    _selectedDestination = destination;
    _destinationController.add(destination.position);

    _cameraCommandController.add(
      MapCameraCommand(position: destination.position, zoom: 18),
    );
  }

  void resumeAutoFollowing() {
    AppLogger().debug("Navigation map autofollow activated");
    _isAutoFollowingUser = true;
    _followStatusController.add(_isAutoFollowingUser);
    if (_lastKnownPosition != null) {
      _cameraCommandController.add(
        MapCameraCommand(position: _lastKnownPosition!),
      );
    }
  }

  void disableAutoFollowing() {
    AppLogger().debug("Navigation map autofollow deactivated");
    _isAutoFollowingUser = false;
    _followStatusController.add(_isAutoFollowingUser);
  }

  void stopDestinationController() {
    if (!_destinationController.isClosed) {
      _destinationController.add(null);
    }
  }

  void prepareNavigation(
    LocationSearchResult destination, {
    bool isRerouting = false,
  }) async {
    if (!isRerouting) moveToLocation(destination);

    if (_lastKnownPosition != null) {
      try {
        final path = await getWalkingPath(
          _lastKnownPosition!,
          destination.position,
        );
        _lastPath = path;

        if (isRerouting) {
          _pathController.add(path);
          AppLogger().info("Reroutage automatique effectué");
        } else {
          _pendingPathController.add(path);
        }
      } catch (e) {
        AppLogger().error("Erreur calcul trajet : $e");
      }
    }
  }

  void confirmNavigation(GeoPath path) {
    _isNavigating = true;
    _pathController.add(path);
    _isNavigatingController.add(true);
    _pendingPathController.add(null);
    AppLogger().debug("Navigation confirmed by user");
  }

  void cancelNavigation() {
    _isNavigating = false;
    _pathController.add(null);
    _destinationController.add(null);
    _pendingPathController.add(null);
    _isNavigatingController.add(false);
    AppLogger().debug("Navigation canceled by user");
  }

  void updatePathProgress(GeoPosition userPos) {
    if (_lastPath == null || _lastPath!.points.isEmpty) return;

    int closestPointIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < _lastPath!.points.length; i++) {
      double dist = _calculateDistance(userPos, _lastPath!.points[i]);
      if (dist < minDistance) {
        minDistance = dist;
        closestPointIndex = i;
      }
    }

    double distanceToFinalDestination = _calculateDistance(
      userPos,
      _lastPath!.points.last,
    );

    if (closestPointIndex >= _lastPath!.points.length - 1 ||
        distanceToFinalDestination < 10) {
      _finishNavigation();
      return;
    }

    if (minDistance > 30 && _selectedDestination != null) {
      AppLogger().info(
        "Utilisateur hors trajet (${minDistance.round()}m). Reroutage...",
      );
      prepareNavigation(_selectedDestination!, isRerouting: true);
      return;
    }

    // clean old passage points
    if (closestPointIndex > 0) {
      final updatedPoints = _lastPath!.points.sublist(closestPointIndex);

      _lastPath = GeoPath(
        points: updatedPoints,
        steps: _lastPath!.steps,
        totalDistance: _lastPath!.totalDistance,
        totalDuration: _lastPath!.totalDuration,
      );

      _pathController.add(_lastPath);
    }
  }

  double _calculateDistance(GeoPosition p1, GeoPosition p2) {
    final Distance distance = const Distance();
    return distance.as(LengthUnit.Meter, p1.toLatLng(), p2.toLatLng());
  }

  void _finishNavigation() {
    _isNavigating = false;
    _isNavigatingController.add(false);
    _pathController.add(null);
    _destinationController.add(null);
    _lastPath = null;
    AppLogger().info("Navigation terminée : l'utilisateur est arrivé.");
  }

  // </editor-fold>
}
