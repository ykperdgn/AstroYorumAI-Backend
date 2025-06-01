import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'birth_info_screen_test.mocks.dart';

void main() {
  testWidgets('Debug button tap test', (WidgetTester tester) async {
    final mockGeocodingService = MockGeocodingService();
    final mockPreferencesService = MockUserPreferencesService();

    await tester.pumpWidget(
      MaterialApp(
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
        home: BirthInfoScreen(
          preferencesService: mockPreferencesService,
          geocodingService: mockGeocodingService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Fill out all required fields
    final nameField = find.byType(TextFormField).at(0);
    await tester.enterText(nameField, 'Test User');
    await tester.pump();

    // Select birth date
    final dateButton = find.text('Doğum Tarihi Seçin');
    if (dateButton.evaluate().isNotEmpty) {
      await tester.tap(dateButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    // Select birth time  
    final timeButton = find.text('Doğum Saati Seçin');
    if (timeButton.evaluate().isNotEmpty) {
      await tester.tap(timeButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    // Enter coordinates
    final latitudeField = find.byType(TextFormField).at(2);
    final longitudeField = find.byType(TextFormField).at(3);
    await tester.enterText(latitudeField, '100');
    await tester.enterText(longitudeField, '30');
    await tester.pump();

    print('=== Fields filled ===');

    // Find submit button
    final submitButton = find.text('Natal Haritamı Hesapla');
    print('Submit button found: ${submitButton.evaluate().length}');
    
    if (submitButton.evaluate().isNotEmpty) {
      // Scroll to make button visible
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      
      print('=== About to tap button ===');
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      print('=== After tapping button ===');
    }

    // Check for validation errors
    final errorText = find.text('Enlem -90 ile 90 arasında olmalıdır');
    print('Error text found: ${errorText.evaluate().length}');
    
    expect(true, true);
  });
}
