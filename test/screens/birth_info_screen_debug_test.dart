import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/services/geocoding_service.dart';

import 'birth_info_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserPreferencesService>(),
  MockSpec<GeocodingService>(),
])
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

    testWidgets('debug validation behavior', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Enter invalid latitude
      await tester.enterText(find.byType(TextFormField).at(2), '95.0');
      await tester.pump();
      
      // Print what's on screen
      debugDumpApp();
      
      // Try to trigger validation by submitting
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump();
      
      // Print all text widgets to see what's actually displayed
      final allText = find.byType(Text);
      for (int i = 0; i < allText.evaluate().length; i++) {
        final widget = tester.widget<Text>(allText.at(i));
        print('Text widget $i: "${widget.data}"');
      }
      
      // Check if any validation text exists
      final validationText = find.textContaining('Enlem');
      print('Found validation text: ${validationText.evaluate().length}');
    });
    
    testWidgets('debug submission behavior without data', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Try to submit empty form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump();
      
      // Print all text widgets to see what happens
      final allText = find.byType(Text);
      for (int i = 0; i < allText.evaluate().length; i++) {
        final widget = tester.widget<Text>(allText.at(i));
        print('Text widget $i after submission: "${widget.data}"');
      }
      
      // Check for SnackBar
      final snackBars = find.byType(SnackBar);
      print('Found SnackBars: ${snackBars.evaluate().length}');
    });
  });
}
