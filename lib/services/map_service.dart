import 'dart:convert';
import 'package:http/http.dart' as http;

class MapService {
  Future<List<dynamic>> fetchNearbyPlaces(double lat, double lng) async {
    final query = '''  
[out:json]; 
(
  node["amenity"="hospital"](around:5000,$lat,$lng);
  node["amenity"="pharmacy"](around:5000,$lat,$lng);
);
out;
''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: query,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['elements'] ?? [];
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching places: $e');
    }
  }
}