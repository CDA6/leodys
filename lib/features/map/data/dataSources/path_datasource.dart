import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PathDatasource {
  Future<Map<String, dynamic>> getRawDirections(
    LatLng start,
    LatLng end,
  ) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=true',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Échec de la récupération du trajet");
    }
  }
}
