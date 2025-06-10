import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/firebase_config_production.dart';
import 'dart:developer' as log;

class AstrologyBackendService {
  // Use the centralized environment configuration
  static String get _baseUrl => AppEnvironment.backendUrl;

  // Turkish translation mappings for client-side fallback
  static const Map<String, String> _planetNamesTurkish = {
    'Sun': 'Güneş',
    'Moon': 'Ay',
    'Mercury': 'Merkür',
    'Venus': 'Venüs',
    'Mars': 'Mars',
    'Jupiter': 'Jüpiter',
    'Saturn': 'Satürn',
  };

  static const Map<String, String> _signNamesTurkish = {
    'Aries': 'Koç',
    'Taurus': 'Boğa',
    'Gemini': 'İkizler',
    'Cancer': 'Yengeç',
    'Leo': 'Aslan',
    'Virgo': 'Başak',
    'Libra': 'Terazi',
    'Scorpio': 'Akrep',
    'Sagittarius': 'Yay',
    'Capricorn': 'Oğlak',
    'Aquarius': 'Kova',
    'Pisces': 'Balık',
  };

  // Convert API response to Turkish if needed
  static Map<String, dynamic> _convertToTurkish(
      Map<String, dynamic> apiResponse) {
    final convertedResponse = Map<String, dynamic>.from(apiResponse);

    // Convert planets to Turkish
    if (convertedResponse.containsKey('planets')) {
      final originalPlanets =
          convertedResponse['planets'] as Map<String, dynamic>;
      final turkishPlanets = <String, dynamic>{};

      originalPlanets.forEach((planetKey, planetData) {
        // Convert planet name to Turkish
        final turkishPlanetName = _planetNamesTurkish[planetKey] ?? planetKey;

        if (planetData is Map<String, dynamic>) {
          final planetInfo = Map<String, dynamic>.from(planetData);

          // Convert sign to Turkish if it exists
          if (planetInfo.containsKey('sign')) {
            final originalSign = planetInfo['sign'] as String;
            final turkishSign = _signNamesTurkish[originalSign] ?? originalSign;
            planetInfo['sign'] = turkishSign;
          }

          turkishPlanets[turkishPlanetName] = planetInfo;
        } else {
          turkishPlanets[turkishPlanetName] = planetData;
        }
      });

      convertedResponse['planets'] = turkishPlanets;
    }

    // Convert ascendant to Turkish
    if (convertedResponse.containsKey('ascendant')) {
      final originalAscendant = convertedResponse['ascendant'] as String;
      final turkishAscendant =
          _signNamesTurkish[originalAscendant] ?? originalAscendant;
      convertedResponse['ascendant'] = turkishAscendant;
    }

    // Add Turkish conversion indicator
    convertedResponse['turkish_converted'] = true;
    convertedResponse['conversion_method'] = 'client_side';
    return convertedResponse;
  }

  // Health check endpoint
  static Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('$_baseUrl/health');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      if (AppEnvironment.enableDebugLogging) {
        log.log('Health check failed: $e');
      }
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getNatalChart({
    required String date, // 'YYYY-MM-DD'
    required String time, // 'HH:MM'
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/natal');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: json.encode({
              'date': date,
              'time': time,
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(const Duration(seconds: 30)); // Add timeout

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        // Convert to Turkish if API doesn't provide Turkish names
        final convertedResult = _convertToTurkish(result);
        return convertedResult;
      }

      return {
        "error": "Backend API Error: ${response.statusCode}",
        "details": response.body,
        "url": url.toString()
      };
    } catch (e) {
      // Specific error type detection with more detailed checks
      String errorMessage = "Bağlantı hatası";
      String userFriendlyMessage = "";
      String specificSolution = "";

      if (e.toString().contains('XMLHttpRequest error') ||
          e.toString().contains('CORS') ||
          e.toString().contains('Access to XMLHttpRequest') ||
          e.toString().contains('blocked by CORS policy') ||
          e.toString().contains('No \'Access-Control-Allow-Origin\'') ||
          e.toString().contains('Access to fetch')) {
        errorMessage = "CORS Browser Güvenlik Hatası";
        userFriendlyMessage =
            "Web tarayıcısı güvenlik politikaları bu isteği engelledi. Bu Flutter web uygulamasının bilinen bir sınırlamasıdır.";
        specificSolution =
            "1. Chrome'u CORS disabled modda açın\n2. Veya mobil uygulamayı kullanın\n3. Veya Firefox tarayıcısını deneyin";
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('ClientException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage = "Ağ bağlantı hatası";
        userFriendlyMessage =
            "İnternet bağlantınızı kontrol edin. Sunucuya erişilemiyor.";
        specificSolution =
            "İnternet bağlantınızı kontrol edin ve tekrar deneyin";
      } else if (e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection timeout')) {
        errorMessage = "Bağlantı zaman aşımı";
        userFriendlyMessage =
            "Sunucu yanıt vermedi. Sunucu yoğunluğu olabilir.";
        specificSolution = "Birkaç dakika bekleyip tekrar deneyin";
      } else if (e.toString().contains('FormatException') ||
          e.toString().contains('JSON')) {
        errorMessage = "Veri format hatası";
        userFriendlyMessage =
            "Sunucudan gelen yanıt bozuk. Sunucu sorunu olabilir.";
        specificSolution = "Daha sonra tekrar deneyin";
      } else {
        userFriendlyMessage =
            "Backend servisine bağlanılamıyor. Teknik sorun olabilir.";
        specificSolution = "Mobil uygulamayı kullanmayı deneyin";
      }

      return {
        "error": errorMessage,
        "user_message": userFriendlyMessage,
        "technical_details": e.toString(),
        "error_type": e.runtimeType.toString(),
        "url": url.toString(),
        "baseUrl": _baseUrl,
        "solution": specificSolution
      };
    }
  }

  // Test method for checking all endpoints
  static Future<Map<String, dynamic>> testAllEndpoints() async {
    final results = <String, dynamic>{};

    // Test health endpoint
    results['health'] = await checkHealth();
    results['baseUrl'] = _baseUrl;
    results['isProduction'] = const bool.fromEnvironment('dart.vm.product');

    // Test natal chart endpoint with sample data
    try {
      final natalResult = await getNatalChart(
        date: '1990-01-01',
        time: '12:00',
        latitude: 41.0082,
        longitude: 28.9784,
      );
      results['natal_test'] =
          natalResult != null && !natalResult.containsKey('error');
      results['natal_response'] = natalResult;
    } catch (e) {
      results['natal_test'] = false;
      results['natal_error'] = e.toString();
    }

    return results;
  }
}
