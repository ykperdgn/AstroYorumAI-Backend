import 'dart:convert';
import 'dart:developer' as log;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Legacy API service for daily horoscopes
class AstrologyApiService {
  static Future<Map<String, dynamic>?> getDailyHoroscope(
      {required String sign}) async {
    final url =
        Uri.parse('https://aztro.sameerkumar.website/?sign=$sign&day=today');

    try {
      // Aztro API'si POST metodu bekliyor.
      final response = await http.post(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      log.log('Aztro API Error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      log.log('Aztro API Exception: $e');
      return null;
    }
  }
}

/// Legacy backend service - Deprecated: Use AstrologyBackendService instead
@Deprecated('Use AstrologyBackendService from astrology_backend_service.dart')
class AstrologyBackendService {
  // Production backend URL - always use HTTPS for production
  static const String _baseUrl = kIsWeb
      ? 'https://astroyorumai-api.onrender.com' // Web production URL
      : 'https://astroyorumai-api.onrender.com'; // Mobile production URL

  @Deprecated('Use AstrologyBackendService from astrology_backend_service.dart')
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
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (kIsWeb) ...{
            'Access-Control-Request-Method': 'POST',
            'Access-Control-Request-Headers': 'Content-Type',
          },
        },
        body: json.encode({
          'date': date,
          'time': time,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        // UTF-8 decode for Turkish characters
        return json.decode(utf8.decode(response.bodyBytes));
      }

      log.log(
          'Legacy Backend API Error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      log.log('Legacy Backend API Exception: $e');
      return null;
    }
  }
}
