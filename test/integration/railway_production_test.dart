import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('Railway Production Deployment Tests', () {
    const String railwayUrl =
        'https://astroyorumai-backend-production.up.railway.app';

    test('Railway health endpoint should respond', () async {
      final response = await http.get(
        Uri.parse('$railwayUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      expect(response.statusCode, equals(200));

      final data = json.decode(response.body);
      expect(data['status'], equals('healthy'));
      expect(data['service'], equals('AstroYorumAI API'));
    });

    test('Railway natal endpoint should work', () async {
      final payload = {
        'date': '1990-06-15',
        'time': '14:30',
        'latitude': 41.0082,
        'longitude': 28.9784,
      };

      final response = await http
          .post(
            Uri.parse('$railwayUrl/natal'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(Duration(seconds: 60));

      expect(response.statusCode, equals(200));

      final data = json.decode(response.body);
      expect(data['planets'], isNotNull);
      expect(data['ascendant'], isNotNull);
      expect(data['calculation_method'], contains('flatlib'));
    });
    test('Railway status endpoint should work', () async {
      final response = await http.get(
        Uri.parse('$railwayUrl/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      expect(response.statusCode, equals(200));

      final data = json.decode(response.body);
      expect(data['status'], isNotNull);
    });

    test('Railway CORS headers should be present', () async {
      final response = await http.get(
        Uri.parse('$railwayUrl/health'),
        headers: {'Origin': 'https://astroyorumai.com'},
      );

      expect(response.headers['access-control-allow-origin'], isNotNull);
      expect(
          response.headers['access-control-allow-methods'], contains('POST'));
    });
  });
}
