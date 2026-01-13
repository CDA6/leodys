import 'package:Leodys/utils/app_logger.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorDatasource {
  Stream<Position> getPositionStream() async* {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger().info("GPS is currently disabled");
      throw 'GPS_DISABLED';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      AppLogger().info("GPS access denied. Ask user permission to use it.");
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        AppLogger().info("GPS access denied");
        throw 'GPS_DENIED';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger().info("GPS access denied forever");
      throw 'GPS_DENIED_FOREVER.';
    }

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    );
  }
}
