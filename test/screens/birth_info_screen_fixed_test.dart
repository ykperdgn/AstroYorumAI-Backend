import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_birth_info.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/services/geocoding_service.dart';
import 'package:astroyorumai/widgets/loading_indicator.dart';

import 'birth_info_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserPreferencesService>(),
  MockSpec<GeocodingService>(),
])
void main() {
  group('BirthInfoScreen Fixed Tests', () {
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

    testWidgets('validates latitude field correctly', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {});

      // Track if save was called (if validation passes, save should be called)
      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {
        saveWasCalled = true;
      });

      // Use a profile with required fields filled
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

      // Enter invalid latitude (>90) and valid longitude
      await tester.enterText(find.byType(TextFormField).at(2), '95'); // Invalid latitude
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
      // If validation worked, save should NOT be called due to invalid latitude
      expect(saveWasCalled, false, reason: 'Form submission should be blocked by validation');
      
      // Verify we're still on the same screen (not navigated away)
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
      expect(find.text('Natal Haritamı Hesapla'), findsOneWidget);
    });

    testWidgets('validates longitude field correctly', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);

      // Track if save was called
      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {
        saveWasCalled = true;
      });

      // Use a profile with required fields filled
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

      // Enter valid latitude and invalid longitude (>180)
      await tester.enterText(find.byType(TextFormField).at(2), '40'); // Valid latitude
      await tester.enterText(find.byType(TextFormField).at(3), '200'); // Invalid longitude
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
      expect(saveWasCalled, false, reason: 'Form submission should be blocked by validation');
      
      // Verify we're still on the same screen
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
      expect(find.text('Natal Haritamı Hesapla'), findsOneWidget);
    });

    testWidgets('allows valid latitude and longitude values', (WidgetTester tester) async {
      // Setup mocks for successful submission
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);

      // Track if save was called
      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {
        saveWasCalled = true;
      });

      // Use a profile with required fields filled
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

      // Verify that form validation allowed submission
      expect(saveWasCalled, true, reason: 'Form submission should succeed with valid data');
    });

    testWidgets('displays processing state when form is submitted with geocoding', (WidgetTester tester) async {
      // Setup: Mock geocoding with a delay
      when(mockGeocodingService.getCoordinates('İstanbul'))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 500));
        return {'lat': 41.0082, 'lon': 28.9784};
      });
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
      });

      // Use a profile with required fields but NO coordinates
      final profile = UserProfile(
        id: 'test-id-processing',
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

      // Add birth place but leave coordinates empty to trigger geocoding
      await tester.enterText(find.byType(TextFormField).at(1), 'İstanbul');
      await tester.pump();

      // Submit form to trigger geocoding
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      
      // Immediately check for processing state
      await tester.pump();
      await tester.pump(Duration(milliseconds: 50));

      // Verify processing state is displayed during geocoding
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Bilgiler işleniyor...'), findsOneWidget);
      
      // Wait for completion
      await tester.pumpAndSettle();
    });
  });
}
