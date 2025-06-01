import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'birth_info_screen_test.mocks.dart';

void main() {
  group('BirthInfoScreen Validation Tests (Simplified)', () {
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

    testWidgets('validates latitude field correctly (blocks submission)', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);

      // Track if save was called
      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {
        saveWasCalled = true;
      });

      final profile = UserProfile(
        id: 'test-id-lat',
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
      );

      // Enter invalid latitude and valid longitude
      await tester.enterText(find.byType(TextFormField).at(2), '100'); // Invalid latitude > 90
      await tester.enterText(find.byType(TextFormField).at(3), '30'); // Valid longitude
      await tester.pump();

      // Submit form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify that form validation prevented submission
      expect(saveWasCalled, false, reason: 'Form submission should be blocked by latitude validation');
      
      // Verify we're still on the same screen
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
    });

    testWidgets('validates longitude field correctly (blocks submission)', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);

      // Track if save was called
      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {
        saveWasCalled = true;
      });

      final profile = UserProfile(
        id: 'test-id-lon',
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
      );

      // Enter valid latitude and invalid longitude
      await tester.enterText(find.byType(TextFormField).at(2), '40'); // Valid latitude
      await tester.enterText(find.byType(TextFormField).at(3), '200'); // Invalid longitude > 180
      await tester.pump();

      // Submit form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify that form validation prevented submission
      expect(saveWasCalled, false, reason: 'Form submission should be blocked by longitude validation');
      
      // Verify we're still on the same screen
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
    });

    testWidgets('allows valid coordinates to submit', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);

      // Track if save was called
      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {
        saveWasCalled = true;
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
        createTestWidget(
          BirthInfoScreen(
            prefilledProfile: profile,
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Enter valid latitude and longitude
      await tester.enterText(find.byType(TextFormField).at(2), '40'); // Valid latitude
      await tester.enterText(find.byType(TextFormField).at(3), '30'); // Valid longitude
      await tester.pump();

      // Submit form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify that form submission succeeded
      expect(saveWasCalled, true, reason: 'Form submission should succeed with valid coordinates');
    });
  });
}
