import 'package:flutter_test/flutter_test.dart';
import '../lib/services/astrology_backend_service.dart';

void main() {
  group('Production API Integration Tests', () {
    test('Health check should succeed', () async {
      final isHealthy = await AstrologyBackendService.checkHealth();
      expect(isHealthy, true);
    });

    test('Natal chart calculation should work', () async {
      final result = await AstrologyBackendService.getNatalChart(
        date: '1990-01-01',
        time: '12:00',
        latitude: 41.0082,
        longitude: 28.9784,
      );

      expect(result, isNotNull);
      expect(result!.containsKey('error'), false);
      expect(result.containsKey('planets'), true);
      expect(result.containsKey('ascendant'), true);

      // Verify Turkish translation is applied
      expect(result.containsKey('turkish_converted'), true);
      expect(result['conversion_method'], 'client_side');

      final planets = result['planets'] as Map<String, dynamic>;
      expect(planets.isNotEmpty, true);

      print('🌟 Natal Chart Test Results:');
      print('   Planets: ${planets.keys.join(', ')}');
      print('   Ascendant: ${result['ascendant']}');
      print('   Turkish converted: ${result['turkish_converted']}');
    });

    test('Test all endpoints should work', () async {
      final testResults = await AstrologyBackendService.testAllEndpoints();

      expect(testResults['health'], true);
      expect(testResults['natal_test'], true);
      expect(testResults['baseUrl'], 'https://astroyorumai-api.onrender.com');

      print('🧪 All Endpoints Test Results:');
      print('   Health: ${testResults['health']}');
      print('   Natal Test: ${testResults['natal_test']}');
      print('   Base URL: ${testResults['baseUrl']}');
      print('   Is Production: ${testResults['isProduction']}');
    });
  });
}
