import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroyorumai/services/localization_service.dart';

void main() {
  group('LocalizationService Tests', () {
    setUp(() {
      // Initialize SharedPreferences with empty data
      SharedPreferences.setMockInitialValues({});
    });

    group('getCurrentLocale', () {
      test('should return system locale when no preference is saved', () async {
        // Act
        final result = await LocalizationService.getCurrentLocale();

        // Assert
        expect(result, isA<Locale>());
        // Note: The actual locale depends on the test environment
      });

      test('should return saved locale preference', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          LocalizationService.localeKey: 'tr',
        });

        // Act
        final result = await LocalizationService.getCurrentLocale();

        // Assert
        expect(result.languageCode, equals('tr'));
      });
    });

    group('setCurrentLocale', () {
      test('should save locale preference', () async {
        // Arrange
        const locale = Locale('en');

        // Act
        await LocalizationService.setCurrentLocale(locale);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(LocalizationService.localeKey), equals('en'));
      });

      test('should handle different locales', () async {
        // Test Turkish
        await LocalizationService.setCurrentLocale(Locale('tr'));
        var prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(LocalizationService.localeKey), equals('tr'));

        // Test English
        await LocalizationService.setCurrentLocale(Locale('en'));
        prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(LocalizationService.localeKey), equals('en'));
      });
    });

    group('getSupportedLocales', () {
      test('should return list of supported locales', () {
        // Act
        final result = LocalizationService.getSupportedLocales();

        // Assert
        expect(result, isA<List<Locale>>());
        expect(result.length, equals(2));
        expect(result.any((locale) => locale.languageCode == 'en'), isTrue);
        expect(result.any((locale) => locale.languageCode == 'tr'), isTrue);
      });
    });

    group('getLanguageDisplayName', () {
      test('should return correct display names for supported languages', () {
        // Test English
        expect(LocalizationService.getLanguageDisplayName('en'), equals('English'));
        
        // Test Turkish
        expect(LocalizationService.getLanguageDisplayName('tr'), equals('Türkçe'));
      });

      test('should return language code for unsupported languages', () {
        // Test unsupported language
        expect(LocalizationService.getLanguageDisplayName('es'), equals('es'));
      });
    });

    group('isSupported', () {
      test('should return true for supported locales', () {
        expect(LocalizationService.isSupported(Locale('en')), isTrue);
        expect(LocalizationService.isSupported(Locale('tr')), isTrue);
      });

      test('should return false for unsupported locales', () {
        expect(LocalizationService.isSupported(Locale('es')), isFalse);
        expect(LocalizationService.isSupported(Locale('fr')), isFalse);
      });
    });
  });
}
