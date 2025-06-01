import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test script to check if the production API is working
void main() async {
  print('🚀 Testing Production API on Render.com');
  print('=====================================');
  
  const productionUrl = 'https://astroyorumai-api.onrender.com';
  
  // Test 1: Health Check
  print('\n📡 1. Testing Health Endpoint...');
  try {
    final healthUrl = Uri.parse('$productionUrl/health');
    final healthResponse = await http.get(healthUrl).timeout(
      const Duration(seconds: 30),
    );
    
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
    print('❌ Health Check: ERROR');
    print('   Error: $e');
  }
  
  // Test 2: Natal Chart Endpoint
  print('\n🔮 2. Testing Natal Chart Endpoint...');
  try {
    final natalUrl = Uri.parse('$productionUrl/natal');
    final natalResponse = await http.post(
      natalUrl,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'date': '1990/06/15',  // Note: Using YYYY/MM/DD format for flatlib
        'time': '14:30',
        'latitude': 41.0082,
        'longitude': 28.9784,
      }),
    ).timeout(const Duration(seconds: 30));
    
    if (natalResponse.statusCode == 200) {
      print('✅ Natal Chart: SUCCESS');
      print('   Status: ${natalResponse.statusCode}');
      
      final responseData = json.decode(natalResponse.body);
      print('   Response Keys: ${responseData.keys.toList()}');
      
      if (responseData.containsKey('planets')) {
        final planets = responseData['planets'] as Map<String, dynamic>;
        print('   Planets found: ${planets.keys.take(3).join(', ')}...');
      }
      
      if (responseData.containsKey('ascendant')) {
        print('   Ascendant: ${responseData['ascendant']}');
      }
    } else {
      print('❌ Natal Chart: FAILED');
      print('   Status: ${natalResponse.statusCode}');
      print('   Response: ${natalResponse.body}');
    }
  } catch (e) {
    print('❌ Natal Chart: ERROR');
    print('   Error: $e');
  }
  
  // Test 3: Response Time Check
  print('\n⏱️  3. Testing Response Times...');
  try {
    final stopwatch = Stopwatch()..start();
    final healthUrl = Uri.parse('$productionUrl/health');
    await http.get(healthUrl).timeout(const Duration(seconds: 10));
    stopwatch.stop();
    
    final responseTime = stopwatch.elapsedMilliseconds;
    print('✅ Response Time: ${responseTime}ms');
    
    if (responseTime < 2000) {
      print('   Performance: EXCELLENT (< 2s)');
    } else if (responseTime < 5000) {
      print('   Performance: GOOD (< 5s)');
    } else {
      print('   Performance: SLOW (> 5s) - Consider optimization');
    }
  } catch (e) {
    print('❌ Response Time Test: ERROR');
    print('   Error: $e');
  }
  
  print('\n=====================================');
  print('🏁 Production API Test Complete');
  print('=====================================');
}
