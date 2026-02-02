import 'dart:math';

import 'package:leodys/features/map/data/dataSources/location_search_datasource.dart';
import 'package:leodys/features/map/data/models/geo_position_model.dart';
import 'package:leodys/features/map/data/models/location_box_model.dart';
import 'package:leodys/features/map/domain/repositories/location_search_repository.dart';
import '../../domain/entities/geo_position.dart';
import '../../domain/entities/location_search_result.dart';

class LocationSearchRepositoryImpl implements ILocationSearchRepository {
  final LocationSearchDatasource dataSource;
  LocationSearchRepositoryImpl(this.dataSource);

  @override
  Future<List<LocationSearchResult>> searchAround(
    String query,
    GeoPosition centerPos,
    double radiusInKm,
  ) async {
    GeoPositionModel centerPosModel = GeoPositionModel.fromEntity(centerPos);
    LocationBoxModel box = _computeBoxFromCenterPos(centerPosModel, radiusInKm);

    final models = await dataSource.searchAddressAround(query, box);
    return models.map((m) => m.toEntity()).toList();
  }

  LocationBoxModel _computeBoxFromCenterPos(
    GeoPositionModel centerPos,
    double radiusKm,
  ) {
    double latOffset = radiusKm / 111.0;
    double lngOffset = radiusKm / (111.0 * cos(centerPos.lat * pi / 180.0));

    return LocationBoxModel(
      lat1: centerPos.lat - latOffset,
      lat2: centerPos.lat + latOffset,
      lng1: centerPos.lng - lngOffset,
      lng2: centerPos.lng + lngOffset,
    );
  }
}
