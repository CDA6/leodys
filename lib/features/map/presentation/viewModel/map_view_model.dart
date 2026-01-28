import 'dart:async';

import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/entities/location_search_result.dart';
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
  // </editor-fold>

  // <editor-fold desc="GeoLocator">
  final WatchUserLocationUseCase watchUserLocation;

  StreamSubscription<GeoPosition>? _locationSubscription;

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
  // </editor-fold>

  MapViewModel(this.watchUserLocation, this.searchAddress);

  // <editor-fold desc="Methods">
  // <editor-fold desc="Lifecycle">
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
  // </editor-fold>

  // <editor-fold desc="GeoLocator">
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
    _positionController.add(destination.position);
  }

  void resumeAutoFollowing() {
    _isAutoFollowingUser = true;
    if (_lastKnownPosition != null) {
      _positionController.add(_lastKnownPosition!);
    }
  }

  void disableAutoFollowing() {
    _isAutoFollowingUser = false;
  }

  // </editor-fold>
}
