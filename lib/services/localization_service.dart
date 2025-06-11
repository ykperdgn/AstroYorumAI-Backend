import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'tr'; // Turkish as default

  // Get current locale
  static Future<Locale> getCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? _defaultLanguage;
    return Locale(languageCode);
  }

  // Set locale
  static Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // Get supported locales
  static List<Locale> getSupportedLocales() {
    return [
      const Locale('tr'), // Turkish
      const Locale('en'), // English
    ];
  }

  // Get language name for display
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Türkçe';
    }
  }

  // Get all available languages for selection
  static Map<String, String> getAvailableLanguages() {
    return {
      'tr': 'Türkçe',
      'en': 'English',
    };
  }

  // Get system locale if supported, otherwise return default
  static Locale getSystemLocale() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supportedCodes =
        getSupportedLocales().map((l) => l.languageCode).toList();

    if (supportedCodes.contains(systemLocale.languageCode)) {
      return systemLocale;
    }

    return const Locale(_defaultLanguage);
  }

  // Initialize with system locale or saved preference
  static Future<Locale> initializeLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage != null) {
      return Locale(savedLanguage);
    }

    // If no saved preference, use system locale
    final systemLocale = getSystemLocale();
    await setLocale(systemLocale.languageCode);
    return systemLocale;
  }

  // Methods expected by tests
  static const String localeKey = _languageKey;

  static Future<void> setCurrentLocale(Locale locale) async {
    await setLocale(locale.languageCode);
  }

  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return languageCode; // Return the language code for unsupported languages
    }
  }

  static bool isSupported(Locale locale) {
    return getSupportedLocales().contains(locale);
  }
}
