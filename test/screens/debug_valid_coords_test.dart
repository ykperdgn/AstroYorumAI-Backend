import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'birth_info_screen_test.mocks.dart';

void main() {
  testWidgets('Debug valid coordinates test', (WidgetTester tester) async {
    final mockGeocodingService = MockGeocodingService();
    final mockPreferencesService = MockUserPreferencesService();

    // Setup mocks
    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => null);

    // Track if save was called
    bool saveWasCalled = false;
    when(mockPreferencesService.saveUserBirthInfo(any))
        .thenAnswer((_) async {
      saveWasCalled = true;
      print('DEBUG: saveUserBirthInfo was called!');
    });

    final profile = UserProfile(
      id: 'test-id-valid',
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
          prefilledProfile: profile,
          preferencesService: mockPreferencesService,
          geocodingService: mockGeocodingService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    print('DEBUG: Entering valid coordinates...');
    // Enter valid latitude and longitude
    await tester.enterText(find.byType(TextFormField).at(2), '40.123456'); // Valid latitude
    await tester.enterText(find.byType(TextFormField).at(3), '32.654321'); // Valid longitude
    await tester.pump();

    print('DEBUG: About to submit form...');
    // Submit form
    final submitButton = find.text('Natal Haritamı Hesapla');
    await tester.dragUntilVisible(
      submitButton,
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    print('DEBUG: Form submitted. saveWasCalled: $saveWasCalled');
    
    // Check if we're still on the same screen or navigated
    final titleFinder = find.text('Doğum Bilgilerini Girin');
    print('DEBUG: Title still found: ${titleFinder.evaluate().length > 0}');
    
    // Verify that form submission succeeded
    expect(saveWasCalled, true, reason: 'Form submission should succeed with valid coordinates');
  });
}
