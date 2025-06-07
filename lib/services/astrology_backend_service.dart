import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_environment.dart';
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
      // Web-specific headers to help with CORS
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      // Add web-specific headers if running on web
      if (kIsWeb) {
        headers.addAll({
          'Access-Control-Request-Method': 'POST',
          'Access-Control-Request-Headers': 'Content-Type',
        });
      }

      final response = await http
          .post(
            url,
            headers: headers,
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
      // Enhanced error handling with specific solutions for web
      String errorMessage = "Bağlantı hatası";
      String userFriendlyMessage = "";
      String specificSolution = "";
      bool isCorsError = false;

      // CORS error detection - more comprehensive
      final corsIndicators = [
        'XMLHttpRequest error',
        'CORS',
        'Access to XMLHttpRequest',
        'blocked by CORS policy',
        'No \'Access-Control-Allow-Origin\'',
        'Access to fetch',
        'Cross-Origin Request Blocked',
        'preflight request',
        'Origin is not allowed'
      ];

      isCorsError = corsIndicators.any((indicator) =>
          e.toString().toLowerCase().contains(indicator.toLowerCase()));

      if (isCorsError) {
        errorMessage = "Web Tarayıcı Güvenlik Kısıtlaması";
        userFriendlyMessage = kIsWeb
            ? "Web tarayıcınız güvenlik nedeniyle bu isteği engelliyor. Bu Flutter web uygulamalarının bilinen bir sınırlamasıdır."
            : "CORS güvenlik politikası hatası oluştu.";
        if (kIsWeb) {
          specificSolution = "Çözüm önerileri:\n"
              "1. Chrome'u '--disable-web-security --user-data-dir=/tmp/chrome-dev' parametreleriyle başlatın\n"
              "2. Firefox tarayıcısını deneyebilirsiniz (bazı durumlarda daha esnek)\n"
              "3. Mobil uygulamayı kullanın (Android/iOS'ta bu sorun yaşanmaz)\n"
              "4. Uygulama sahibinden proxy/CORS çözümü talep edin";
        } else {
          specificSolution = "Sunucu CORS ayarlarını kontrol edin";
        }
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
        specificSolution = kIsWeb
            ? "Web tarayıcısı sınırlamaları nedeniyle sorun olabilir. Mobil uygulamayı deneyin."
            : "Mobil uygulamayı kullanmayı deneyin";
      }

      return {
        "error": errorMessage,
        "user_message": userFriendlyMessage,
        "technical_details": e.toString(),
        "error_type": e.runtimeType.toString(),
        "url": url.toString(),
        "baseUrl": _baseUrl,
        "solution": specificSolution,
        "is_cors_error": isCorsError,
        "platform": kIsWeb ? "web" : "mobile",
        "timestamp": DateTime.now().toIso8601String()
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

  // NEW ADVANCED ASTROLOGY ENDPOINTS

  /// Calculate Synastry (Compatibility Analysis) between two people
  static Future<Map<String, dynamic>?> getSynastryAnalysis({
    required String person1Name,
    required String person1Date,
    required String person1Time,
    required double person1Latitude,
    required double person1Longitude,
    required String person2Name,
    required String person2Date,
    required String person2Time,
    required double person2Latitude,
    required double person2Longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/synastry');

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      final response = await http
          .post(
            url,
            headers: headers,
            body: json.encode({
              'person1': {
                'name': person1Name,
                'date': person1Date,
                'time': person1Time,
                'latitude': person1Latitude,
                'longitude': person1Longitude,
              },
              'person2': {
                'name': person2Name,
                'date': person2Date,
                'time': person2Time,
                'latitude': person2Latitude,
                'longitude': person2Longitude,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        return result;
      }

      return {
        "error": "Synastry API Error: ${response.statusCode}",
        "details": response.body,
      };
    } catch (e) {
      return {
        "error": "Synastry bağlantı hatası",
        "technical_details": e.toString(),
        "timestamp": DateTime.now().toIso8601String()
      };
    }
  }

  /// Calculate Current Transits affecting natal chart
  static Future<Map<String, dynamic>?> getTransitAnalysis({
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    String? transitDate, // Optional, defaults to today
  }) async {
    final url = Uri.parse('$_baseUrl/transit');

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      final requestBody = {
        'birth_date': birthDate,
        'birth_time': birthTime,
        'latitude': latitude,
        'longitude': longitude,
      };

      if (transitDate != null) {
        requestBody['transit_date'] = transitDate;
      }

      final response = await http
          .post(
            url,
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        return result;
      }

      return {
        "error": "Transit API Error: ${response.statusCode}",
        "details": response.body,
      };
    } catch (e) {
      return {
        "error": "Transit analizi bağlantı hatası",
        "technical_details": e.toString(),
        "timestamp": DateTime.now().toIso8601String()
      };
    }
  }

  /// Calculate Solar Return Chart for a specific year
  static Future<Map<String, dynamic>?> getSolarReturn({
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    required int year,
  }) async {
    final url = Uri.parse('$_baseUrl/solar-return');

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      final response = await http
          .post(
            url,
            headers: headers,
            body: json.encode({
              'birth_date': birthDate,
              'birth_time': birthTime,
              'latitude': latitude,
              'longitude': longitude,
              'year': year,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        return result;
      }

      return {
        "error": "Solar Return API Error: ${response.statusCode}",
        "details": response.body,
      };
    } catch (e) {
      return {
        "error": "Solar Return analizi bağlantı hatası",
        "technical_details": e.toString(),
        "timestamp": DateTime.now().toIso8601String()
      };
    }
  }

  /// Calculate Secondary Progressions
  static Future<Map<String, dynamic>?> getProgressionAnalysis({
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    String? progressionDate, // Optional, defaults to today
  }) async {
    final url = Uri.parse('$_baseUrl/progression');

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      final requestBody = {
        'birth_date': birthDate,
        'birth_time': birthTime,
        'latitude': latitude,
        'longitude': longitude,
      };

      if (progressionDate != null) {
        requestBody['progression_date'] = progressionDate;
      }

      final response = await http
          .post(
            url,
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        return result;
      }

      return {
        "error": "Progression API Error: ${response.statusCode}",
        "details": response.body,
      };
    } catch (e) {
      return {
        "error": "Progression analizi bağlantı hatası",
        "technical_details": e.toString(),
        "timestamp": DateTime.now().toIso8601String()
      };
    }
  }

  /// Enhanced Horary Astrology for specific questions
  static Future<Map<String, dynamic>?> getHoraryAnalysis({
    required String question,
    required double latitude,
    required double longitude,
    String? questionTime, // Optional, defaults to now
  }) async {
    final url = Uri.parse('$_baseUrl/horary');

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      final requestBody = {
        'question': question,
        'latitude': latitude,
        'longitude': longitude,
      };

      if (questionTime != null) {
        requestBody['question_time'] = questionTime;
      }

      final response = await http
          .post(
            url,
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        return result;
      }

      return {
        "error": "Horary API Error: ${response.statusCode}",
        "details": response.body,
      };
    } catch (e) {
      return {
        "error": "Horary analizi bağlantı hatası",
        "technical_details": e.toString(),
        "timestamp": DateTime.now().toIso8601String()
      };
    }
  }

  /// Calculate Composite Chart for relationship analysis
  static Future<Map<String, dynamic>?> getCompositeChart({
    required String person1Name,
    required String person1Date,
    required String person1Time,
    required double person1Latitude,
    required double person1Longitude,
    required String person2Name,
    required String person2Date,
    required String person2Time,
    required double person2Latitude,
    required double person2Longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/composite');

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      final response = await http
          .post(
            url,
            headers: headers,
            body: json.encode({
              'person1': {
                'name': person1Name,
                'date': person1Date,
                'time': person1Time,
                'latitude': person1Latitude,
                'longitude': person1Longitude,
              },
              'person2': {
                'name': person2Name,
                'date': person2Date,
                'time': person2Time,
                'latitude': person2Latitude,
                'longitude': person2Longitude,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        return result;
      }

      return {
        "error": "Composite Chart API Error: ${response.statusCode}",
        "details": response.body,
      };
    } catch (e) {
      return {
        "error": "Composite Chart bağlantı hatası",
        "technical_details": e.toString(),
        "timestamp": DateTime.now().toIso8601String()
      };
    }
  }

  /// Test all new advanced endpoints
  static Future<Map<String, dynamic>> testAdvancedEndpoints() async {
    final results = <String, dynamic>{};

    // Sample data for testing
    const testDate1 = '1990-05-15';
    const testTime1 = '14:30:00';
    const testLat1 = 41.0082;
    const testLon1 = 28.9784;

    const testDate2 = '1992-08-22';
    const testTime2 = '09:15:00';
    const testLat2 = 39.9334;
    const testLon2 = 32.8597;

    // Test Synastry
    try {
      final synastryResult = await getSynastryAnalysis(
        person1Name: 'Test Person 1',
        person1Date: testDate1,
        person1Time: testTime1,
        person1Latitude: testLat1,
        person1Longitude: testLon1,
        person2Name: 'Test Person 2',
        person2Date: testDate2,
        person2Time: testTime2,
        person2Latitude: testLat2,
        person2Longitude: testLon2,
      );
      results['synastry'] =
          synastryResult != null && !synastryResult.containsKey('error');
    } catch (e) {
      results['synastry'] = false;
      results['synastry_error'] = e.toString();
    }

    // Test Transit
    try {
      final transitResult = await getTransitAnalysis(
        birthDate: testDate1,
        birthTime: testTime1,
        latitude: testLat1,
        longitude: testLon1,
      );
      results['transit'] =
          transitResult != null && !transitResult.containsKey('error');
    } catch (e) {
      results['transit'] = false;
      results['transit_error'] = e.toString();
    }

    // Test Solar Return
    try {
      final solarResult = await getSolarReturn(
        birthDate: testDate1,
        birthTime: testTime1,
        latitude: testLat1,
        longitude: testLon1,
        year: 2024,
      );
      results['solar_return'] =
          solarResult != null && !solarResult.containsKey('error');
    } catch (e) {
      results['solar_return'] = false;
      results['solar_return_error'] = e.toString();
    }

    // Test Progression
    try {
      final progressionResult = await getProgressionAnalysis(
        birthDate: testDate1,
        birthTime: testTime1,
        latitude: testLat1,
        longitude: testLon1,
      );
      results['progression'] =
          progressionResult != null && !progressionResult.containsKey('error');
    } catch (e) {
      results['progression'] = false;
      results['progression_error'] = e.toString();
    }

    // Test Horary
    try {
      final horaryResult = await getHoraryAnalysis(
        question: 'Test sorusu için analiz',
        latitude: testLat1,
        longitude: testLon1,
      );
      results['horary'] =
          horaryResult != null && !horaryResult.containsKey('error');
    } catch (e) {
      results['horary'] = false;
      results['horary_error'] = e.toString();
    }

    // Test Composite
    try {
      final compositeResult = await getCompositeChart(
        person1Name: 'Test Person 1',
        person1Date: testDate1,
        person1Time: testTime1,
        person1Latitude: testLat1,
        person1Longitude: testLon1,
        person2Name: 'Test Person 2',
        person2Date: testDate2,
        person2Time: testTime2,
        person2Latitude: testLat2,
        person2Longitude: testLon2,
      );
      results['composite'] =
          compositeResult != null && !compositeResult.containsKey('error');
    } catch (e) {
      results['composite'] = false;
      results['composite_error'] = e.toString();
    }

    return results;
  }
}
