import 'dart:convert';
import 'package:http/http.dart' as http;

class MapService {
  Future<List<dynamic>> fetchNearbyPlaces(double lat, double lng) async {
    // Optimized Overpass query for hospitals and pharmacies
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="hospital"](around:5000,$lat,$lng);
  node["amenity"="pharmacy"](around:5000,$lat,$lng);
  way["amenity"="hospital"](around:5000,$lat,$lng);
  way["amenity"="pharmacy"](around:5000,$lat,$lng);
);
out body;
>;
out skel qt;
''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'NaijaMeds/1.0', // Required to avoid 406 error
          'Accept': 'application/json',
        },
        // Correctly formatting the body for Overpass API
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['elements'] ?? [];
      } else {
        print('MapService Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      print('MapService Exception: $e');
      throw Exception('Error fetching places: $e');
    }
  }
}
