import 'dart:convert';
import 'dart:io';

/// Simple Railway Backend Test
/// Tests backend connectivity using native Dart HTTP
void main() async {
  print('🎯 Simple Railway Backend Test');
  print('=' * 50);

  const String railwayUrl =
      'https://astroyorumai-backend-production.up.railway.app';

  // Test 1: Health Check
  print('\n1️⃣ Testing Health Endpoint...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('$railwayUrl/health'));
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      print('   ✅ Health Check: SUCCESS');
      print('   📊 Status: ${data['status']}');
      print('   🚂 Platform: ${data['platform']}');
    } else {
      print('   ❌ Health Check Failed: ${response.statusCode}');
    }
    client.close();
  } catch (e) {
    print('   ❌ Health Check Error: $e');
  }

  // Test 2: Natal Chart Test
  print('\n2️⃣ Testing Natal Chart API...');
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$railwayUrl/natal'));
    request.headers.set('Content-Type', 'application/json');

    final testData = {
      'date': '1990-01-01',
      'time': '12:00',
      'latitude': 41.0082,
      'longitude': 28.9784,
    };

    request.write(json.encode(testData));
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      print('   ✅ Natal Chart API: SUCCESS');
      print('   🌟 Ascendant: ${data['ascendant']}');
      print('   🪐 Planet count: ${(data['planets'] as Map).length}');
    } else {
      print('   ❌ Natal Chart API Failed: ${response.statusCode}');
    }
    client.close();
  } catch (e) {
    print('   ❌ Natal Chart API Error: $e');
  }

  print('\n' + '=' * 50);
  print('✅ Railway Backend Test Complete!');
}
