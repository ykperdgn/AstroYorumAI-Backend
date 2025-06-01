import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/services/geocoding_service.dart';

import 'birth_info_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserPreferencesService>(),
  MockSpec<GeocodingService>(),
])
void main() {
  group('BirthInfoScreen Validation Debug', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
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
        home: child,
      );
    }

    testWidgets('DEBUG: Check validation behavior step by step', (WidgetTester tester) async {
      // Use profile with date/time set to bypass early validation checks
      final profile = UserProfile(
        id: 'debug-test-id',
        name: 'Test User',
        birthDate: DateTime(1985, 12, 25),
        birthTime: '14:30',
        birthPlace: null,
        latitude: null,
        longitude: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            prefilledProfile: profile,
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );      print('=== INITIAL STATE ===');
      final initialForms = find.byType(Form);
      print('Forms found: ${initialForms.evaluate().length}');

      // Enter invalid latitude
      print('=== ENTERING INVALID LATITUDE ===');
      await tester.enterText(find.byType(TextFormField).at(2), '95.0'); // Invalid latitude > 90
      await tester.enterText(find.byType(TextFormField).at(3), '30.0'); // Valid longitude
      await tester.pump();

      // Check if validation happens when field loses focus
      print('=== CHECKING FOCUS CHANGE VALIDATION ===');
      await tester.tap(find.byType(TextFormField).at(0)); // Focus on name field
      await tester.pump();

      // Print all text widgets to see if validation appeared
      print('All text widgets after focus change:');
      for (var element in find.byType(Text).evaluate()) {
        final widget = element.widget as Text;
        if (widget.data != null && widget.data!.contains('Enlem')) {
          print('  Found Enlem text: "${widget.data}"');
        }
      }

      // Now try to submit form to trigger validation
      print('=== SUBMITTING FORM ===');
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump(); // Allow validation messages to appear

      print('All text widgets after form submission:');
      for (var element in find.byType(Text).evaluate()) {
        final widget = element.widget as Text;
        if (widget.data != null && (widget.data!.contains('Enlem') || widget.data!.contains('90'))) {
          print('  Found validation-related text: "${widget.data}"');
        }
      }

      // Check for any error text styles or decoration
      print('=== CHECKING FOR ERROR INDICATORS ===');
      final errorTexts = tester.widgetList<Text>(find.byType(Text))
          .where((text) => text.style?.color == Colors.red || 
                          text.style?.color == Colors.red[700] ||
                          text.style?.color == Colors.red[800])
          .toList();
      print('Found ${errorTexts.length} red-colored texts');
      for (var text in errorTexts) {
        print('  Red text: "${text.data}"');
      }      // Look for any error-related widgets
      final inputDecorators = find.byType(InputDecorator);
      print('InputDecorators found: ${inputDecorators.evaluate().length}');
    });
  });
}
