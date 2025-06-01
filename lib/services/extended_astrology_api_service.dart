import 'dart:convert';
import 'package:http/http.dart' as http;

class ExtendedAstrologyApiService {
  static const String _baseUrl = 'https://aztro.sameerkumar.website';

  static Future<Map<String, dynamic>?> getHoroscope({
    required String sign,
    String period = 'today', // 'today', 'week', 'month'
  }) async {
    final url = Uri.parse('$_baseUrl?sign=$sign&day=$period');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Horoscope API error: $e');
    }
    return null;
  }
}
