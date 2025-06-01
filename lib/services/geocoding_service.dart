import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  Future<Map<String, double>?> getCoordinates(String place) async {
    final encodedPlace = Uri.encodeComponent(place);
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedPlace&format=json&addressdetails=1&limit=1&accept-language=tr');
    
    print('GeocodingService: Requesting URL: $url'); // For debugging

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'AstroYorumAI/1.0 (astroyorumai.app@gmail.com)' // Updated User-Agent
      });

      if (response.statusCode == 200) {
        final results = json.decode(utf8.decode(response.bodyBytes));
        if (results is List && results.isNotEmpty) {
          final data = results[0];
          final latString = data['lat'];
          final lonString = data['lon'];
          
          final lat = double.tryParse(latString.toString());
          final lon = double.tryParse(lonString.toString());

          if (lat != null && lon != null) {
            print('GeocodingService: Found coordinates for "$place": Lat: $lat, Lon: $lon');
            return {
              'lat': lat,
              'lon': lon,
            };
          } else {
            print('GeocodingService: Latitude or Longitude could not be parsed from response: $data');
            return null; // Indicates parsing failure
          }
        } else {
          print('GeocodingService: No results found for "$place". Response body: ${utf8.decode(response.bodyBytes)}');
          return null; // Indicates place not found
        }
      } else {
        print('GeocodingService Error: Status Code ${response.statusCode} for "$place". Response body: ${utf8.decode(response.bodyBytes)}');
        // Consider throwing a specific exception or returning an error object for better handling upstream
        return null; // Indicates HTTP error
      }
    } catch (e, stackTrace) {
      print('GeocodingService Exception for "$place": $e\n$stackTrace');
      // Consider re-throwing or returning a specific error object
      return null; // Indicates general exception (e.g., network issue)
    }  }
}
