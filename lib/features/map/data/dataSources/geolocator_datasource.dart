import 'package:geolocator/geolocator.dart';

import '../exceptions/geolocator_exceptions.dart';

class GeolocatorDatasource {
  Stream<Position> getPositionStream() async* {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw GpsServiceException();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw GpsPermissionException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw GpsPermissionForeverException();
    }

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    );
  }
}
