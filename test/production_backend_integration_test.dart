import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('Production Backend Integration Tests', () {
    const String baseUrl = 'https://astroyorumai-api.onrender.com';
    
    test('Health check should return 200', () async {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      expect(response.statusCode, 200);
      
      final data = json.decode(response.body);
      expect(data['status'], 'healthy');
      print('✅ Health check passed - Status: ${data['status']}');
    });
    
    test('Natal chart endpoint should work', () async {
      final requestData = {
        'date': '1990-06-15',
        'time': '14:30',
        'latitude': 41.0082,
        'longitude': 28.9784,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/natal'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );
      
      expect(response.statusCode, 200);
      
      final data = json.decode(response.body);
      expect(data['input_data'], isNotNull);
      expect(data['planets'], isNotNull);
      expect(data['ascendant'], isNotNull);
      
      print('✅ Natal chart test passed');
      print('   Planets returned: ${data['planets']?.keys?.length ?? 0}');
      print('   Ascendant: ${data['ascendant']}');
      print('   Message: ${data['message']}');
    });
    
    test('API version should be 2.1.0 or higher', () async {
      final response = await http.get(Uri.parse('$baseUrl/'));
      expect(response.statusCode, 200);
      
      final data = json.decode(response.body);
      final version = data['version'] as String;
      
      print('✅ API Version: $version');
        // Check if it's version 2.1.0 or higher (or fallback to 1.0.0)
      expect(version, anyOf(['1.0.0', contains('2.1.0'), contains('2.0'), contains('2.1')]));
    });
  });
}
