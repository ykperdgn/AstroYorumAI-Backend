import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔧 CORS Debug Test - AstroYorumAI');
  print('Platform: Dart Console');
  print('Testing production API from Dart...');

  const String baseUrl = 'https://astroyorumai-api.onrender.com';

  try {
    // Test 1: Health Check
    print('\n📊 Test 1: Health Check');
    final healthResponse = await http.get(
      Uri.parse('$baseUrl/health'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Access-Control-Request-Method': 'GET',
        'Access-Control-Request-Headers': 'Content-Type',
      },
    );

    print('Status: ${healthResponse.statusCode}');
    if (healthResponse.statusCode == 200) {
      print('✅ Health check successful');
      print('Response: ${healthResponse.body}');
    } else {
      print('❌ Health check failed');
      print('Response: ${healthResponse.body}');
    }

    // Test 2: Natal Chart
    print('\n🌟 Test 2: Natal Chart Calculation');
    final natalResponse = await http.post(
      Uri.parse('$baseUrl/natal'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Access-Control-Request-Method': 'POST',
        'Access-Control-Request-Headers': 'Content-Type',
      },
      body: json.encode({
        'date': '1990-06-15',
        'time': '14:30',
        'latitude': 41.0082,
        'longitude': 28.9784,
      }),
    );

    print('Status: ${natalResponse.statusCode}');
    if (natalResponse.statusCode == 200) {
      print('✅ Natal chart calculation successful');
      final data = json.decode(natalResponse.body);
      print('Planets found: ${data['planets']?.keys.length ?? 0}');
      print('Ascendant: ${data['ascendant'] ?? 'N/A'}');
    } else {
      print('❌ Natal chart calculation failed');
      print('Response: ${natalResponse.body}');
    }
  } catch (e) {
    print('\n❌ Error occurred: $e');
    print('Error type: ${e.runtimeType}');

    // Check for CORS-specific errors
    if (e.toString().contains('XMLHttpRequest') ||
        e.toString().contains('CORS') ||
        e.toString().contains('Access-Control')) {
      print('\n🚨 CORS Error Detected!');
      print('This is a browser security restriction.');
      print('\nSolutions:');
      print('1. Use Chrome with CORS disabled (already provided)');
      print('2. Deploy to same domain as API');
      print('3. Use mobile app (no CORS restrictions)');
      print('4. Set up development proxy server');
    }
  }

  print('\n✅ Debug test completed');
}
