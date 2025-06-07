import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/services/astrology_backend_service.dart';

void main() {
  group('Desktop Platform API Tests', () {
    testWidgets('Desktop should not have CORS restrictions', (WidgetTester tester) async {
      // Test that the API works on desktop platforms
      final result = await AstrologyBackendService.getNatalChart(
        date: '1990-06-15',
        time: '14:30',
        latitude: 41.0082,
        longitude: 28.9784,
      );

      expect(result, isNotNull);
      expect(result!.containsKey('error'), false);
      expect(result.containsKey('planets'), true);
      expect(result.containsKey('ascendant'), true);

      print('🖥️ Desktop Test Results:');
      print('   Success: ${!result.containsKey('error')}');
      print('   Planets: ${result['planets']?.keys.join(', ') ?? 'None'}');
      print('   Ascendant: ${result['ascendant'] ?? 'N/A'}');
    });

    test('Health check should work on desktop', () async {
      final isHealthy = await AstrologyBackendService.checkHealth();
      expect(isHealthy, true);
      print('🏥 Desktop Health Check: ✅ Passed');
    });

    test('All endpoints test on desktop', () async {
      final testResults = await AstrologyBackendService.testAllEndpoints();
      
      expect(testResults['health'], true);
      expect(testResults['natal_test'], true);
      
      print('🧪 Desktop All Endpoints Test:');
      print('   Health: ${testResults['health']}');
      print('   Natal: ${testResults['natal_test']}');
      print('   Base URL: ${testResults['baseUrl']}');
    });
  });
}
