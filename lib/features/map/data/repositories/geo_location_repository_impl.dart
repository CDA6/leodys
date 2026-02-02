import 'package:dartz/dartz.dart';
import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/data/exceptions/geolocator_exceptions.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/failures/gps_failures.dart';
import 'package:leodys/features/map/domain/repositories/geo_location_repository.dart';

class GeoLocationRepositoryImpl implements GeoLocationRepository {
  final GeolocatorDatasource dataSource;

  GeoLocationRepositoryImpl(this.dataSource);
  GeoPosition? _lastKnowPosition;

  @override
  GeoPosition? getLastCachedPosition() => _lastKnowPosition;

  @override
  Stream<Either<GpsFailure, GeoPosition>> watchPosition() {
    Stream<Either<GpsFailure, GeoPosition>> createStream() async* {
      try {
        await for (final pos in dataSource.getPositionStream()) {
          final geoPos = GeoPosition(
            latitude: pos.latitude,
            longitude: pos.longitude,
            accuracy: pos.accuracy,
          );

          _lastKnowPosition = geoPos;
          yield Right(geoPos);
        }
      } catch (error) {
        if (error is GpsServiceException) {
          yield Left(GpsDisabledFailure());
        } else if (error is GpsPermissionException) {
          yield Left(GpsPermissionDeniedFailure());
        } else if (error is GpsPermissionForeverException) {
          yield Left(GpsPermissionForeverDeniedFailure());
        } else {
          yield Left(GpsUnknownFailure());
        }
      }
    }

    return createStream().distinct((prev, next) {
      return prev.fold(
        (fPrev) => next.fold(
          (fNext) => fPrev.runtimeType == fNext.runtimeType,
          (_) => false,
        ),
        (pPrev) => next.fold(
          (_) => false,
          (pNext) =>
              pPrev.latitude == pNext.latitude &&
              pPrev.longitude == pNext.longitude &&
              pPrev.accuracy == pNext.accuracy,
        ),
      );
    });
  }
}
