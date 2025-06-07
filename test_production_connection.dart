import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🚀 Testing AstroYorumAI Production API Connection...\n');

  const baseUrl = 'https://astroyorumai-api.onrender.com';

  // Test 1: Health Check
  print('📊 Testing Health Endpoint...');
  try {
    final healthResponse = await http.get(Uri.parse('$baseUrl/health'));
    if (healthResponse.statusCode == 200) {
      print('✅ Health Check: SUCCESS');
      print('   Status: ${healthResponse.statusCode}');
      print('   Response: ${healthResponse.body}');
    } else {
      print('❌ Health Check: FAILED');
      print('   Status: ${healthResponse.statusCode}');
      print('   Response: ${healthResponse.body}');
    }
  } catch (e) {
    print('❌ Health Check: ERROR - $e');
  }

  print('\n' + '=' * 50 + '\n');

  // Test 2: Root Endpoint
  print('🏠 Testing Root Endpoint...');
  try {
    final rootResponse = await http.get(Uri.parse(baseUrl));
    if (rootResponse.statusCode == 200) {
      print('✅ Root Endpoint: SUCCESS');
      print('   Status: ${rootResponse.statusCode}');
      final responseBody = rootResponse.body;
      if (responseBody.length > 200) {
        print('   Response: ${responseBody.substring(0, 200)}...');
      } else {
        print('   Response: $responseBody');
      }
    } else {
      print('❌ Root Endpoint: FAILED');
      print('   Status: ${rootResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Root Endpoint: ERROR - $e');
  }

  print('\n' + '=' * 50 + '\n');

  // Test 3: Natal Chart Endpoint
  print('🌟 Testing Natal Chart Endpoint...');
  try {
    final natalResponse = await http.post(
      Uri.parse('$baseUrl/natal'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'date': '1990-01-01',
        'time': '12:00',
        'latitude': 41.0082,
        'longitude': 28.9784,
      }),
    );

    if (natalResponse.statusCode == 200) {
      print('✅ Natal Chart: SUCCESS');
      print('   Status: ${natalResponse.statusCode}');

      final natalData = json.decode(natalResponse.body);
      print('   Has planets: ${natalData.containsKey('planets')}');
      print('   Has ascendant: ${natalData.containsKey('ascendant')}');

      if (natalData.containsKey('planets')) {
        final planets = natalData['planets'] as Map<String, dynamic>;
        print('   Planet count: ${planets.length}');
        print('   Planets: ${planets.keys.join(', ')}');

        // Show sample planet data
        if (planets.containsKey('Sun')) {
          final sunData = planets['Sun'];
          print('   Sun example: $sunData');
        }
      }

      if (natalData.containsKey('ascendant')) {
        print('   Ascendant: ${natalData['ascendant']}');
      }
    } else {
      print('❌ Natal Chart: FAILED');
      print('   Status: ${natalResponse.statusCode}');
      print('   Response: ${natalResponse.body}');
    }
  } catch (e) {
    print('❌ Natal Chart: ERROR - $e');
  }

  print('\n' + '=' * 50 + '\n');
  print('🎯 Production API Test Complete!');
}
