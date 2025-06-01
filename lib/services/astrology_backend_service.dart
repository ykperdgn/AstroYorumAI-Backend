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
  
  // Helper method to manually test with production URL during development
  static String get productionUrl => _productionUrl;
  
  // Health check endpoint
  static Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('$_baseUrl/health');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
  static Future<Map<String, dynamic>?> getNatalChart({
    required String date, // 'YYYY-MM-DD'
    required String time, // 'HH:MM'
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/natal');
    try {
      print('Making request to: $url'); // Debug log
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'date': date,
          'time': time,
          'latitude': latitude,
          'longitude': longitude,
        }),
      ).timeout(const Duration(seconds: 30)); // Add timeout
      
      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        print('API Response: Success'); // Debug log
        return result;
      }
      
      print('AstrologyBackendService Error: ${response.statusCode} - ${response.body}');
      return {
        "error": "Backend API Error: ${response.statusCode}", 
        "details": response.body,
        "url": url.toString()
      };
    } catch (e) {
      print('Error connecting to AstrologyBackendService: $e');
      print('Attempted URL: $url');
      return {
        "error": "Cannot connect to backend service: $e",
        "url": url.toString(),
        "baseUrl": _baseUrl
      };
    }
  }
  
  // Test method for checking all endpoints
  static Future<Map<String, dynamic>> testAllEndpoints() async {
    final results = <String, dynamic>{};
    
    // Test health endpoint
    results['health'] = await checkHealth();
    results['baseUrl'] = _baseUrl;
    results['isProduction'] = bool.fromEnvironment('dart.vm.product');
    
    // Test natal chart endpoint with sample data
    try {
      final natalResult = await getNatalChart(
        date: '1990-01-01',
        time: '12:00',
        latitude: 41.0082,
        longitude: 28.9784,
      );
      results['natal_test'] = natalResult != null && !natalResult.containsKey('error');
      results['natal_response'] = natalResult;
    } catch (e) {
      results['natal_test'] = false;
      results['natal_error'] = e.toString();
    }
    
    return results;
  }
}
