import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test script to verify Flutter app can connect to Railway backend
/// This tests the production Railway deployment integration
void main() async {
  print('🚀 AstroYorumAI Flutter → Railway Backend Integration Test');
  print('=' * 60);

  // Test URLs - Production Railway backend
  const String railwayBaseUrl =
      'https://astroyorumai-backend-production.up.railway.app';

  // Test 1: Health Check
  print('\n1️⃣ Testing Health Endpoint...');
  await testHealthEndpoint(railwayBaseUrl);

  // Test 2: Natal Chart API
  print('\n2️⃣ Testing Natal Chart API...');
  await testNatalChartAPI(railwayBaseUrl);

  // Test 3: Environment Configuration Test
  print('\n3️⃣ Testing Flutter Environment Configuration...');
  testFlutterEnvironmentConfig();

  print('\n' + '=' * 60);
  print('✅ Flutter → Railway Integration Test Complete!');
  print('   Next step: Run Flutter app and test manually');
}

Future<void> testHealthEndpoint(String baseUrl) async {
  try {
    final url = Uri.parse('$baseUrl/health');
    print('   Testing: $url');

    final response = await http.get(url).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('   ✅ Health Check: SUCCESS');
      print('   📊 Status: ${data['status']}');
      print('   🕐 Server Time: ${data['timestamp']}');
      if (data.containsKey('version')) {
        print('   📋 Version: ${data['version']}');
      }
    } else {
      print('   ❌ Health Check Failed: ${response.statusCode}');
      print('   📄 Response: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Health Check Error: $e');
  }
}

Future<void> testNatalChartAPI(String baseUrl) async {
  try {
    final url = Uri.parse('$baseUrl/natal');
    print('   Testing: $url');

    // Sample data for testing
    final testData = {
      'date': '1990-01-01',
      'time': '12:00',
      'latitude': 41.0082,
      'longitude': 28.9784,
    };

    print('   📤 Sending test data: $testData');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: json.encode(testData),
        )
        .timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('   ✅ Natal Chart API: SUCCESS');
      print('   🌟 Has planets: ${data.containsKey('planets')}');
      print('   🔮 Has ascendant: ${data.containsKey('ascendant')}');

      if (data.containsKey('planets')) {
        final planets = data['planets'] as Map<String, dynamic>;
        print('   🪐 Planet count: ${planets.length}');
        print('   🌍 Available planets: ${planets.keys.take(5).join(', ')}...');

        // Test specific planet data structure
        if (planets.containsKey('Sun')) {
          final sunData = planets['Sun'];
          print('   ☀️ Sun data structure: $sunData');

          if (sunData is Map) {
            print('   🎯 Sun sign: ${sunData['sign']}');
            print('   📐 Sun degree: ${sunData['degree']}');
          }
        }
      }

      if (data.containsKey('ascendant')) {
        print('   ⬆️ Ascendant: ${data['ascendant']}');
      }

      // Check response time
      print('   ⏱️ Response received successfully');
    } else {
      print('   ❌ Natal Chart API Failed: ${response.statusCode}');
      print('   📄 Response: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Natal Chart API Error: $e');
  }
}

void testFlutterEnvironmentConfig() {
  print('   🔧 Testing Flutter Environment Configuration...');

  // Simulate different environment configurations
  const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // Test both web and mobile configurations
  for (final isWeb in [false, true]) {
    String backendUrl;
    if (isProduction) {
      backendUrl = 'https://astroyorumai-backend-production.up.railway.app';
    } else {
      backendUrl = isWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
    }

    print(
        '   ${isWeb ? '🌐' : '📱'} ${isWeb ? 'Web' : 'Mobile'} - ${isProduction ? 'Production' : 'Development'}:');
    print('      Backend URL: $backendUrl');

    // Test URL validity
    try {
      final uri = Uri.parse(backendUrl);
      print('      ✅ URL valid - Host: ${uri.host}, Scheme: ${uri.scheme}');
    } catch (e) {
      print('      ❌ URL invalid: $e');
    }
  }

  print('   ✅ Environment Configuration: VALID');
}
