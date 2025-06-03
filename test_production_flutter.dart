import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

void main() async {
  developer.log('🧪 Testing Flutter app connection to production API...');
  
  const String productionUrl = 'https://astroyorumai-api.onrender.com';
  
  // Test health endpoint
  developer.log('\n1. Testing health endpoint...');
  try {
    final healthResponse = await http.get(Uri.parse('$productionUrl/health'));
    if (healthResponse.statusCode == 200) {
      developer.log('✅ Health check: SUCCESS');
      developer.log('   Response: ${healthResponse.body}');
    } else {
      developer.log('❌ Health check failed: ${healthResponse.statusCode}');
    }
  } catch (e) {
    developer.log('❌ Health check error: $e');
  }
  
  // Test natal chart endpoint
  developer.log('\n2. Testing natal chart endpoint...');
  try {
    final natalData = {
      'date': '1990-01-01',
      'time': '12:00',
      'latitude': 41.0082,
      'longitude': 28.9784
    };
    
    final natalResponse = await http.post(
      Uri.parse('$productionUrl/natal'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(natalData),
    );
      if (natalResponse.statusCode == 200) {
      developer.log('✅ Natal chart: SUCCESS');
      final response = json.decode(natalResponse.body);
      developer.log('   Response keys: ${response.keys.toList()}');
    } else {
      developer.log('❌ Natal chart failed: ${natalResponse.statusCode}');
    }
  } catch (e) {
    developer.log('❌ Natal chart error: $e');
  }
  
  developer.log('\n🎉 Production API connectivity test completed!');
}
