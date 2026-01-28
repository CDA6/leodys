import 'package:leodys/features/map/data/models/geo_position_model.dart';
import 'package:leodys/features/map/domain/entities/location_search_result.dart';

class LocationSearchResultModel {
  final String label;
  final GeoPositionModel position;

  LocationSearchResultModel({required this.label, required this.position});

  factory LocationSearchResultModel.fromJson(Map<String, dynamic> json) {
    return LocationSearchResultModel(
      label: json['display_name'] ?? '',
      position: GeoPositionModel(
        double.parse(json['lat']),
        double.parse(json['lon']),
      ),
    );
  }

  LocationSearchResult toEntity() =>
      LocationSearchResult(name: label, position: this.position.toEntity());
}
