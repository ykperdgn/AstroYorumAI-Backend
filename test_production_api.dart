import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

/// Test script to check if the production API is working
void main() async {
  developer.log('🚀 Testing Production API on Render.com');
  developer.log('=====================================');
  
  const productionUrl = 'https://astroyorumai-api.onrender.com';
    // Test 1: Health Check
  developer.log('\n📡 1. Testing Health Endpoint...');
  try {
    final healthUrl = Uri.parse('$productionUrl/health');
    final healthResponse = await http.get(healthUrl).timeout(
      const Duration(seconds: 30),
    );
    
    if (healthResponse.statusCode == 200) {
      developer.log('✅ Health Check: SUCCESS');
      developer.log('   Status: ${healthResponse.statusCode}');
      developer.log('   Response: ${healthResponse.body}');
    } else {
      developer.log('❌ Health Check: FAILED');
      developer.log('   Status: ${healthResponse.statusCode}');
      developer.log('   Response: ${healthResponse.body}');
    }
  } catch (e) {
    developer.log('❌ Health Check: ERROR');
    developer.log('   Error: $e');
  }
    // Test 2: Natal Chart Endpoint
  developer.log('\n🔮 2. Testing Natal Chart Endpoint...');
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
      developer.log('✅ Natal Chart: SUCCESS');
      developer.log('   Status: ${natalResponse.statusCode}');
      
      final responseData = json.decode(natalResponse.body);
      developer.log('   Response Keys: ${responseData.keys.toList()}');
      
      if (responseData.containsKey('planets')) {
        final planets = responseData['planets'] as Map<String, dynamic>;
        developer.log('   Planets found: ${planets.keys.take(3).join(', ')}...');
      }
      
      if (responseData.containsKey('ascendant')) {
        developer.log('   Ascendant: ${responseData['ascendant']}');
      }
    } else {
      developer.log('❌ Natal Chart: FAILED');
      developer.log('   Status: ${natalResponse.statusCode}');
      developer.log('   Response: ${natalResponse.body}');
    }
  } catch (e) {
    developer.log('❌ Natal Chart: ERROR');
    developer.log('   Error: $e');
  }
    // Test 3: Response Time Check
  developer.log('\n⏱️  3. Testing Response Times...');
  try {
    final stopwatch = Stopwatch()..start();
    final healthUrl = Uri.parse('$productionUrl/health');
    await http.get(healthUrl).timeout(const Duration(seconds: 10));
    stopwatch.stop();
    
    final responseTime = stopwatch.elapsedMilliseconds;
    developer.log('✅ Response Time: ${responseTime}ms');
    
    if (responseTime < 2000) {
      developer.log('   Performance: EXCELLENT (< 2s)');
    } else if (responseTime < 5000) {
      developer.log('   Performance: GOOD (< 5s)');
    } else {
      developer.log('   Performance: SLOW (> 5s) - Consider optimization');
    }} catch (e) {
    developer.log('❌ Response Time Test: ERROR');
    developer.log('   Error: $e');
  }
  
  developer.log('\n=====================================');
  developer.log('🏁 Production API Test Complete');
  developer.log('=====================================');
}
