import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

Future<void> main() async {
  developer.log('🧪 AstroYorumAI Flutter Backend Bağlantı Testi');
  developer.log('===============================================');

  const String apiUrl = 'https://astroyorumai-api.onrender.com';

  // Test 1: API Sağlık Kontrolü
  developer.log('\n🔍 1️⃣ API Sağlık Kontrolü...');
  try {
    final response = await http.get(Uri.parse('$apiUrl/health'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      developer.log('✅ Backend çalışıyor!');
      developer.log('   Versiyon: ${data['version']}');
      developer.log('   Durum: ${data['status']}');
    } else {
      developer.log('❌ Backend bağlantı hatası: ${response.statusCode}');
    }
  } catch (e) {
    developer.log('❌ Backend bağlantı hatası: $e');
  }

  // Test 2: Doğum Haritası Testi
  developer.log('\n🪐 2️⃣ Doğum Haritası API Testi...');
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/natal'),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: json.encode({
        'date': '1990-06-15',
        'time': '14:30',
        'latitude': 41.0082,
        'longitude': 28.9784,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      developer.log('✅ Doğum haritası API çalışıyor!');
      developer.log('   Versiyon: ${data['version']}');
      developer.log('   Yükselen: ${data['ascendant']}');
      developer.log('   Gezegen sayısı: ${data['planets']?.length ?? 0}');

      // Örnek gezegen verisi göster
      if (data['planets'] != null) {
        final planets = data['planets'] as Map<String, dynamic>;
        if (planets.isNotEmpty) {
          final firstPlanet = planets.entries.first;
          developer.log('   Örnek (${firstPlanet.key}): ${firstPlanet.value}');
        }
      }
    } else {
      developer.log('❌ Doğum haritası API hatası: ${response.statusCode}');
      developer.log('   Hata mesajı: ${response.body}');
    }
  } catch (e) {
    developer.log('❌ Doğum haritası API hatası: $e');
  }

  developer.log('\n===============================================');
  developer.log('🎯 Test tamamlandı!');
  developer.log('✅ Eğer tüm testler başarılı ise Flutter uygulaması çalışmalı');
}
