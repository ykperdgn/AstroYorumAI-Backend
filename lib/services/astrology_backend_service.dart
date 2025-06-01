import 'dart:convert';
import 'package:http/http.dart' as http;

class AstrologyBackendService {
  // Kendi backend sunucunuzun adresini buraya yazın
  // Eğer emülatörde test ediyorsanız ve sunucu aynı makinede çalışıyorsa,
  // Android emülatörü için 'http://10.0.2.2:5000/natal' kullanabilirsiniz.
  // iOS simülatörü veya gerçek cihaz için makinenizin yerel IP adresini kullanın (örn: 'http://192.168.1.X:5000/natal')
  // Web için ve localhost'taki sunucu için 'http://localhost:5000/natal' genellikle çalışır.
  static const String _baseUrl = 'http://localhost:5000'; // Varsayılan olarak localhost

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
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'date': date,
          'time': time,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      print('AstrologyBackendService Error: ${response.statusCode} - ${response.body}');
      return {"error": "Backend API Error: ${response.statusCode}", "details": response.body};
    } catch (e) {
      print('Error connecting to AstrologyBackendService: $e');
      return {"error": "Cannot connect to backend service: $e"};
    }
  }
}
