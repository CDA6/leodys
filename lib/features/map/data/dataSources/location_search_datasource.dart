import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leodys/features/map/data/models/geo_position_model.dart';
import 'package:leodys/features/map/data/models/location_box_model.dart';
import 'package:leodys/features/map/data/models/location_search_result_model.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';

class LocationSearchDatasource {
  Future<List<LocationSearchResultModel>> searchAddressAround(
    String query,
    LocationBoxModel box,
  ) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=jsonv2&limit=6&addressdetails=1&namedetails=1&layers=address,poi&viewbox=${box.lng1},${box.lat1},${box.lng2},${box.lat2}&bounded=0&countrycodes=fr',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'LeodysApp/1.0'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data
          .map((item) => LocationSearchResultModel.fromJson(item))
          .toList();
    } else {
      throw Exception("An error occurred during the research");
    }
  }
}
