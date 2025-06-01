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
  group('BirthInfoScreen Validation Tests (Fixed)', () {
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
      // Setup: Mock services
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {});

      // Use a profile with required fields filled to bypass early validation checks
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

      // Find the latitude field (3rd TextFormField - index 2)
      final latitudeField = find.byType(TextFormField).at(2);
      final longitudeField = find.byType(TextFormField).at(3);
      
      // Enter invalid latitude value (outside -90 to 90 range)
      await tester.enterText(latitudeField, '95');
      // Enter valid longitude value
      await tester.enterText(longitudeField, '30');
      await tester.pump();

      // Scroll down to ensure the submit button is visible
      await tester.dragUntilVisible(
        find.text('Natal Haritamı Hesapla'),
        find.byType(ListView),
        const Offset(0, -100),      );

      // Submit the form to trigger validation
      await tester.tap(find.text('Natal Haritamı Hesapla'), warnIfMissed: false);
      await tester.pumpAndSettle(); // Wait for all animations and validations

      // The form validation should show an error for invalid latitude
      expect(find.text('Enlem -90 ile 90 arasında olmalıdır'), findsOneWidget);
    });

    testWidgets('validates longitude field correctly', (WidgetTester tester) async {
      // Setup: Mock services
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {});

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

      // Find the latitude and longitude fields
      final latitudeField = find.byType(TextFormField).at(2);
      final longitudeField = find.byType(TextFormField).at(3);
      
      // Enter valid latitude and invalid longitude (outside -180 to 180 range)
      await tester.enterText(latitudeField, '40');
      await tester.enterText(longitudeField, '200');
      await tester.pump();

      // Scroll down to ensure the submit button is visible
      await tester.dragUntilVisible(
        find.text('Natal Haritamı Hesapla'),
        find.byType(ListView),
        const Offset(0, -100),      );

      // Submit the form to trigger validation
      await tester.tap(find.text('Natal Haritamı Hesapla'), warnIfMissed: false);
      await tester.pumpAndSettle(); // Wait for all animations and validations

      // The form validation should show an error for invalid longitude
      expect(find.text('Boylam -180 ile 180 arasında olmalıdır'), findsOneWidget);
    });

    testWidgets('displays processing state when form is submitted with geocoding', (WidgetTester tester) async {
      // Setup: Mock geocoding with a delay to capture processing state
      when(mockGeocodingService.getCoordinates('İstanbul'))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 200));
        return {'lat': 41.0082, 'lon': 28.9784};
      });
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
      });

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

      // Verify coordinates are empty (this is critical for geocoding path)
      final latField = tester.widget<TextFormField>(find.byType(TextFormField).at(2));
      final lonField = tester.widget<TextFormField>(find.byType(TextFormField).at(3));
      expect(latField.controller?.text, isEmpty);
      expect(lonField.controller?.text, isEmpty);

      // Submit form to trigger geocoding
      await tester.dragUntilVisible(
        find.text('Natal Haritamı Hesapla'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('Natal Haritamı Hesapla'));
      
      // Immediately check for processing state
      await tester.pump(); // Let setState take effect
      await tester.pump(Duration(milliseconds: 50)); // Allow processing state to appear

      // Verify processing state is displayed during geocoding
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Bilgiler işleniyor...'), findsOneWidget);
      
      // Let geocoding complete
      await tester.pumpAndSettle();
    });

    testWidgets('allows valid latitude and longitude values to submit', (WidgetTester tester) async {
      // Setup: Mock successful operations
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => {'lat': 41.0082, 'lon': 28.9784});
      
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
            onComplete: (birthInfo) {
              // Callback is called on successful submission
            },
          ),
        ),
      );

      // Enter valid coordinates
      await tester.enterText(find.byType(TextFormField).at(2), '40.0'); // Valid latitude
      await tester.enterText(find.byType(TextFormField).at(3), '30.0'); // Valid longitude
      await tester.pump();
      
      // Submit form
      await tester.dragUntilVisible(
        find.text('Natal Haritamı Hesapla'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('Natal Haritamı Hesapla'));
      await tester.pumpAndSettle(); // Wait for async operations
      
      // Verify that save was called (meaning form submission succeeded)
      expect(saveWasCalled, isTrue);
    });
  });
}
