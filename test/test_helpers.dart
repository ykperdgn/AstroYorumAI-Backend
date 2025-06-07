import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/services/geocoding_service.dart';

/// Shared MockGeocodingService implementation for all tests
/// This replaces duplicate code blocks across different test files
class SharedMockGeocodingService implements GeocodingService {
  @override
  Future<Map<String, double>?> getCoordinates(String location) async {
    // Return mock coordinates for known locations
    final mockData = {
      'Istanbul': {'lat': 41.0082, 'lon': 28.9784},
      'İstanbul': {'lat': 41.0082, 'lon': 28.9784},
      'Ankara': {'lat': 39.9334, 'lon': 32.8597},
      'Izmir': {'lat': 38.4192, 'lon': 27.1287},
      'İzmir': {'lat': 38.4192, 'lon': 27.1287},
      'New York': {'lat': 40.7128, 'lon': -74.0060},
      'London': {'lat': 51.5074, 'lon': -0.1278},
    };
    
    return mockData[location];
  }
}

/// Helper function to create a properly configured MaterialApp for testing
Widget createTestApp(Widget child) {
  return MaterialApp(
    home: child,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('tr', 'TR'),
      Locale('en', 'US'),
    ],
    locale: const Locale('tr', 'TR'),
  );
}

/// Helper function to create a MaterialApp with specific settings for testing
Widget createTestAppWithSettings({
  required Widget child,
  Locale? locale,
  List<Locale>? supportedLocales,
  ThemeData? theme,
}) {
  return MaterialApp(
    home: child,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: supportedLocales ?? const [
      Locale('tr', 'TR'),
      Locale('en', 'US'),
    ],
    locale: locale ?? const Locale('tr', 'TR'),
    theme: theme,
  );
}
