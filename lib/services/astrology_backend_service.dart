import 'dart:convert';
import 'package:http/http.dart' as http;

class AstrologyBackendService {
  // Production URL - Update this with your actual Render.com deployment URL
  static const String _productionUrl = 'https://astroyorumai-api.onrender.com';
  
  // Development URLs for local testing
  static const String _localhostUrl = 'http://localhost:5000';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:5000';
  
  // Automatically detect environment and use appropriate URL
  static String get _baseUrl {
    // In production builds, use production URL
    // In debug mode, use localhost for development
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      return _productionUrl;
    }
    
    // For development, try to detect platform
    // Default to localhost for development
    return _localhostUrl;
  }

  static Future<Map<String, dynamic>?> getNatalChart({
    required String date, // 'YYYY-MM-DD'
    required String time, // 'HH:MM'
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/natal');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'date': date,
          'time': time,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      print('AstrologyBackendService Error: ${response.statusCode} - ${response.body}');
      return {"error": "Backend API Error: ${response.statusCode}", "details": response.body};
    } catch (e) {
      print('Error connecting to AstrologyBackendService: $e');
      return {"error": "Cannot connect to backend service: $e"};
    }
  }
}
