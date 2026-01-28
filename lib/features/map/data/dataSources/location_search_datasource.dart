import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leodys/features/map/data/models/location_search_result_model.dart';

class LocationSearchDatasource {
  Future<List<LocationSearchResultModel>> searchAddress(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1',
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
