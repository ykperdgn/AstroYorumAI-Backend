import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Flutter app connection to production API...');
  
  const String productionUrl = 'https://astroyorumai-api.onrender.com';
  
  // Test health endpoint
  print('\n1. Testing health endpoint...');
  try {
    final healthResponse = await http.get(Uri.parse('$productionUrl/health'));
    if (healthResponse.statusCode == 200) {
      print('✅ Health check: SUCCESS');
      print('   Response: ${healthResponse.body}');
    } else {
      print('❌ Health check failed: ${healthResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Health check error: $e');
  }
  
  // Test natal chart endpoint
  print('\n2. Testing natal chart endpoint...');
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
      print('✅ Natal chart: SUCCESS');
      final response = json.decode(natalResponse.body);
      print('   Response keys: ${response.keys.toList()}');
    } else {
      print('❌ Natal chart failed: ${natalResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Natal chart error: $e');
  }
  
  print('\n🎉 Production API connectivity test completed!');
}
