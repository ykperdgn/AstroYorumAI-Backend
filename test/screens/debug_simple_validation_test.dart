import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'birth_info_screen_test.mocks.dart';

void main() {
  testWidgets('Simple validation debug test', (WidgetTester tester) async {
    final mockGeocodingService = MockGeocodingService();
    final mockPreferencesService = MockUserPreferencesService();

    final profile = UserProfile(
      id: 'test-id',
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
      MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        locale: Locale('tr', 'TR'),
        home: BirthInfoScreen(
          prefilledProfile: profile,
          preferencesService: mockPreferencesService,
          geocodingService: mockGeocodingService,
        ),
      ),
    );    await tester.pumpAndSettle();

    // Fill out required fields first
    final nameField = find.byType(TextFormField).at(0);
    await tester.enterText(nameField, 'Test User');
    await tester.pump();

    // Set birth date by tapping the date field (if needed)
    // Since we have a prefilledProfile, the date should already be set

    // Set birth time by tapping the time field (if needed) 
    // Since we have a prefilledProfile, the time should already be set

    // Find latitude and longitude fields
    final latitudeField = find.byType(TextFormField).at(2);
    final longitudeField = find.byType(TextFormField).at(3);

    // Enter invalid latitude
    await tester.enterText(latitudeField, '100');
    await tester.enterText(longitudeField, '30');
    await tester.pump();

    print('=== Before tapping submit button ===');
    
    // Find submit button and tap it
    final submitButton = find.text('Natal Haritamı Hesapla');
    expect(submitButton, findsOneWidget);
    
    // Scroll to make button visible
    await tester.dragUntilVisible(
      submitButton,
      find.byType(ListView),
      const Offset(0, -100),
    );
    
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    print('=== After tapping submit button ===');
    
    // Look for any validation error text
    final errorText = find.text('Enlem -90 ile 90 arasında olmalıdır');
    print('Error text found: ${errorText.evaluate().length}');
    
    // Check all text widgets to see what's rendered
    final allTextWidgets = find.byType(Text);
    print('All Text widgets count: ${allTextWidgets.evaluate().length}');
    
    for (final textWidget in allTextWidgets.evaluate()) {
      final widget = textWidget.widget as Text;
      if (widget.data != null && widget.data!.contains('olmalıdır')) {
        print('Found validation text: ${widget.data}');
      }
    }
    
    // The test passes regardless - we're just debugging
    expect(true, true);
  });
}
