// Debug test to understand actual app behavior
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/services/geocoding_service.dart';

import 'birth_info_screen_test.mocks.dart';

void main() {
  group('BirthInfoScreen Debug Tests', () {
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

    testWidgets('DEBUG: What happens with invalid latitude?', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Fill form with invalid latitude
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(2), '95.0'); // Invalid latitude
      await tester.enterText(find.byType(TextFormField).at(3), '30.0'); // Valid longitude
      
      print('=== BEFORE SUBMIT ===');
      print('TextFormFields found: ${find.byType(TextFormField).evaluate().length}');
      print('Submit button found: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
      
      // Submit form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump();
      
      print('=== AFTER SUBMIT ===');
      print('All text widgets:');
      for (var element in find.byType(Text).evaluate()) {
        final widget = element.widget as Text;
        if (widget.data != null) {
          print('  Text: "${widget.data}"');
        }
      }
      
      print('All error messages containing "Enlem":');
      final enlemFinder = find.textContaining('Enlem');
      print('  Found ${enlemFinder.evaluate().length} widgets');
      for (var element in enlemFinder.evaluate()) {
        final widget = element.widget as Text;
        print('  Error text: "${widget.data}"');
      }
      
      print('SnackBars found: ${find.byType(SnackBar).evaluate().length}');
      
      // Check if we can find the exact validation message
      final validationMessage = find.text('Enlem -90 ile 90 arasında olmalıdır');
      print('Exact validation message found: ${validationMessage.evaluate().length}');
    });

    testWidgets('DEBUG: What happens when submitting without date?', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Fill other fields but not date
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(2), '41.0');
      await tester.enterText(find.byType(TextFormField).at(3), '29.0');
      
      print('=== BEFORE SUBMIT (no date) ===');
      
      // Submit form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump();
      
      print('=== AFTER SUBMIT (no date) ===');
      print('All text widgets:');
      for (var element in find.byType(Text).evaluate()) {
        final widget = element.widget as Text;
        if (widget.data != null && widget.data!.contains('doğum')) {
          print('  Text containing "doğum": "${widget.data}"');
        }
      }
      
      print('SnackBars found: ${find.byType(SnackBar).evaluate().length}');
      print('Material (SnackBar container) found: ${find.byType(Material).evaluate().length}');
      
      // Check for the specific date message
      final dateMessage = find.text('Lütfen doğum tarihinizi seçin.');
      print('Date validation message found: ${dateMessage.evaluate().length}');
    });
  });
}
