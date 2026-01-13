import 'package:geolocator/geolocator.dart';

class GeolocatorDatasource {
  Stream<Position> getPositionStream() async* {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'GPS_DISABLED';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'GPS_DENIED';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'GPS_DENIED_FOREVER.';
    }

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    );
  }
}
