import 'package:leodys/features/map/domain/failures/map_failure.dart';

abstract class GpsFailure extends MapFailure {
  GpsFailure(super.message);
}

class GpsDisabledFailure extends GpsFailure {
  GpsDisabledFailure() : super("Le GPS est désactivé sur votre appareil.");
}

class GpsPermissionDeniedFailure extends GpsFailure {
  GpsPermissionDeniedFailure() : super("L'accès à la position a été refusé.");
}

class GpsPermissionForeverDeniedFailure extends GpsFailure {
  GpsPermissionForeverDeniedFailure()
    : super("L'accès à la position a été refusé définitivement.");
}

class GpsUnknownFailure extends GpsFailure {
  GpsUnknownFailure()
    : super("Une erreur de localisation inconnue est survenue.");
}
