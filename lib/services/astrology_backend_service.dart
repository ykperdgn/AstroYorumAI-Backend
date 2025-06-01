import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/firebase_config_production.dart';

class AstrologyBackendService {  // Use the centralized environment configuration
  static String get _baseUrl => AppEnvironment.backendUrl;
  
  // Health check endpoint
  static Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('$_baseUrl/health');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      if (AppEnvironment.enableDebugLogging) {
        print('Health check failed: $e');
      }
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
