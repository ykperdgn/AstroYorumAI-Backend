import 'dart:convert';
import 'dart:io';

void main() async {
  const baseUrl = 'https://astroyorumai-api.onrender.com';

  print('🔍 Backend API Connectivity Test');
  print('📡 Testing: $baseUrl');
  print('=' * 50);

  final client = HttpClient();

  try {
    // Health check
    print('1️⃣ Health Check...');
    final healthRequest = await client.getUrl(Uri.parse('$baseUrl/health'));
    final healthResponse = await healthRequest.close();
    final healthStatus = healthResponse.statusCode;
    print('   Status: $healthStatus ${healthStatus == 200 ? "✅" : "❌"}');

    if (healthStatus == 200) {
      final healthBody = await healthResponse.transform(utf8.decoder).join();
      print('   Response: $healthBody');
    }

    // Natal chart test
    print('\n2️⃣ Natal Chart API Test...');
    final natalRequest =
        await client.postUrl(Uri.parse('$baseUrl/natal-chart'));
    natalRequest.headers.contentType = ContentType.json;

    final testData = {
      'birth_date': '1990-06-15',
      'birth_time': '14:30',
      'birth_place': 'Istanbul',
      'latitude': 41.0082,
      'longitude': 28.9784
    };

    natalRequest.add(utf8.encode(jsonEncode(testData)));
    final natalResponse = await natalRequest.close();
    final natalStatus = natalResponse.statusCode;
    print('   Status: $natalStatus ${natalStatus == 200 ? "✅" : "❌"}');

    if (natalStatus == 200) {
      final natalBody = await natalResponse.transform(utf8.decoder).join();
      final natalData = jsonDecode(natalBody);
      print('   Planets found: ${natalData['planets']?.length ?? 0}');
      print('   Houses found: ${natalData['houses']?.length ?? 0}');
      print('   Ascendant: ${natalData['ascendant'] ?? 'N/A'}');
    }

    print('\n✅ Backend API Test Completed');
  } catch (e) {
    print('❌ Connection Error: $e');
    if (e.toString().contains('SocketException')) {
      print('💡 This might be a CORS issue or backend unavailability');
    }
  } finally {
    client.close();
  }
}
