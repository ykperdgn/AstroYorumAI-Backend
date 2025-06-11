import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

// Debug script to test the exact API connection issue using HttpClient
void main() async {
  developer.log('🔍 Debug: Testing API Connection Issue');
  developer.log('=========================================');

  const String apiUrl =
      'https://astroyorumai-api.onrender.com'; // Test 1: Health check
  developer.log('\n1️⃣ Testing Health Endpoint...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('$apiUrl/health'));
    final response = await request.close();
    developer.log('✅ Health Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final healthData = json.decode(responseBody);
      developer.log('   Version: ${healthData['version']}');
    }
    client.close();
  } catch (e) {
    developer.log('❌ Health Error: $e');
  } // Test 2: Natal Chart with real data
  developer.log('\n2️⃣ Testing Natal Chart Endpoint...');
  try {
    final testData = {
      'date': '1990-01-01',
      'time': '12:00',
      'latitude': 41.0082,
      'longitude': 28.9784,
    };

    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$apiUrl/natal'));
    request.headers.set('Content-Type', 'application/json');
    request.write(json.encode(testData));
    final response = await request.close();

    developer.log('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      developer.log('✅ Natal Chart Success!');
      developer.log('   Version: ${data['version']}');
      developer.log('   Planets count: ${data['planets']?.length ?? 0}');
      developer.log('   Ascendant: ${data['ascendant']}');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      developer.log('❌ Error Response: $responseBody');
    }
    client.close();
  } catch (e) {
    developer.log('❌ Connection Error: $e');
  } // Test 3: Test the exact same call as Flutter service
  developer.log('\n3️⃣ Testing Flutter Service Simulation...');
  try {
    final testData = {
      'date': '1990-01-01',
      'time': '12:00',
      'latitude': 41.0082,
      'longitude': 28.9784,
    };

    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$apiUrl/natal'));
    request.headers.set('Content-Type', 'application/json; charset=UTF-8');
    request.write(json.encode(testData));
    final response = await request.close();

    developer.log('Flutter Style Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final result = json.decode(responseBody);
      developer.log('✅ Flutter Style Success!');
      developer.log('   Response Type: ${result.runtimeType}');
      developer.log('   Has Error Key: ${result.containsKey('error')}');
      if (result.containsKey('error')) {
        developer.log('   Error: ${result['error']}');
      } else {
        developer.log('   Version: ${result['version']}');
        developer.log(
            '   Planets: ${result['planets'] != null ? "Present" : "Missing"}');
      }
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      developer
          .log('❌ Flutter Style Error: ${response.statusCode} - $responseBody');
    }
    client.close();
  } catch (e) {
    developer.log('❌ Flutter Style Exception: $e');
  }

  developer.log('\n=========================================');
  developer.log('🏁 Debug Test Complete');
}
