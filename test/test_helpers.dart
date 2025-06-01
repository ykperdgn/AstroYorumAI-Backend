import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
