import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

Future<void> main() async {
  developer.log('🔍 Testing Flutter App Connection to Production API');
  developer.log('===================================================');
    // Test production API URL
  const String productionUrl = 'https://astroyorumai-api.onrender.com';
    // Test 1: Health Check
  developer.log('\n1️⃣ Testing Health Endpoint...');
  try {
    final healthResponse = await http.get(Uri.parse('$productionUrl/health'));
    if (healthResponse.statusCode == 200) {
      developer.log('✅ Health check successful');
      developer.log('   Response: ${healthResponse.body}');
    } else {
      developer.log('❌ Health check failed: ${healthResponse.statusCode}');
    }
  } catch (e) {
    developer.log('❌ Health check error: $e');
  }
    // Test 2: Status Check
  developer.log('\n2️⃣ Testing Status Endpoint...');
  try {
    final statusResponse = await http.get(Uri.parse('$productionUrl/status'));
    if (statusResponse.statusCode == 200) {
      final statusData = json.decode(statusResponse.body);
      developer.log('✅ Status check successful');
      developer.log('   Version: ${statusData['version']}');
      developer.log('   Status: ${statusData['status']}');
    } else {
      developer.log('❌ Status check failed: ${statusResponse.statusCode}');
    }
  } catch (e) {
    developer.log('❌ Status check error: $e');
  }
    // Test 3: Natal Chart API
  developer.log('\n3️⃣ Testing Natal Chart Endpoint...');
  try {
    final natalResponse = await http.post(
      Uri.parse('$productionUrl/natal'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'date': '1990-06-15',
        'time': '14:30',
        'latitude': 41.0082,
        'longitude': 28.9784,
      }),
    );
    
    if (natalResponse.statusCode == 200) {
      final natalData = json.decode(natalResponse.body);
      developer.log('✅ Natal chart API successful');
      developer.log('   Version: ${natalData['version']}');
      developer.log('   Ascendant: ${natalData['ascendant']}');
      developer.log('   Planets count: ${natalData['planets']?.length ?? 0}');
      
      // Show sample planet data
      if (natalData['planets'] != null) {
        final planets = natalData['planets'] as Map<String, dynamic>;
        if (planets.isNotEmpty) {
          final firstPlanet = planets.entries.first;
          developer.log('   Sample (${firstPlanet.key}): ${firstPlanet.value}');
        }
      }
    } else {
      developer.log('❌ Natal chart failed: ${natalResponse.statusCode}');
      developer.log('   Response: ${natalResponse.body}');
    }
  } catch (e) {
    developer.log('❌ Natal chart error: $e');
  }
  
  developer.log('\n===================================================');
  developer.log('🎉 Flutter App Production API Test Complete!');
  developer.log('✅ If all tests passed, Flutter app is ready for production');
}
