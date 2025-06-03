import 'dart:convert';
import 'dart:developer' as log;
import 'package:http/http.dart' as http;

class AstrologyApiService {
  static Future<Map<String, dynamic>?> getDailyHoroscope({required String sign}) async {
    final url = Uri.parse('https://aztro.sameerkumar.website/?sign=$sign&day=today');
    // Aztro API'si POST metodu bekliyor.
    final response = await http.post(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    log.log('Aztro API Error: ${response.statusCode} - ${response.body}'); // Hata durumunda loglama
    return null;
  }
}

class AstrologyBackendService { // Yeni servis sınıfı
  // Kendi backend sunucunuzun adresini buraya yazın
  // Eğer emülatörde test ediyorsanız ve sunucu aynı makinede çalışıyorsa,
  // Android emülatörü için 'http://10.0.2.2:5000/natal' kullanabilirsiniz.
  // iOS simülatörü veya gerçek cihaz için makinenizin yerel IP adresini kullanın (örn: 'http://192.168.1.X:5000/natal')
  static const String _baseUrl = 'http://10.0.2.2:5000'; // Android emülatörü için varsayılan

  static Future<Map<String, dynamic>?> getNatalChart({
    required String date, // 'YYYY-MM-DD'
    required String time, // 'HH:MM'
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/natal');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'}, // charset eklendi
        body: json.encode({
          'date': date,
          'time': time,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      if (response.statusCode == 200) {
        // UTF-8 decode eklendi, Türkçe karakterler için önemli
        return json.decode(utf8.decode(response.bodyBytes)); 
      }
      log.log('Backend API Error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      log.log('Error connecting to backend API: $e');
      return null;
    }
  }
}
