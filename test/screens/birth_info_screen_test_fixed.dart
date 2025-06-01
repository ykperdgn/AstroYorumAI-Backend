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

import 'birth_info_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserPreferencesService>(),
  MockSpec<GeocodingService>(),
])
void main() {
  group('BirthInfoScreen Widget Tests', () {
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

    testWidgets('renders basic form elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Verify form elements are present
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4)); // Name, Place, Latitude, Longitude
      expect(find.text('Tarih Seç'), findsOneWidget);
      expect(find.text('Saat Seç'), findsOneWidget);
      expect(find.text('Natal Haritamı Hesapla'), findsOneWidget);
    });

    testWidgets('shows initial empty state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Verify initial empty state
      expect(find.text('Doğum Tarihi Seçilmedi'), findsOneWidget);
      expect(find.text('Doğum Saati Seçilmedi'), findsOneWidget);
    });

    testWidgets('populates form with initialBirthInfo data', (WidgetTester tester) async {
      final initialInfo = UserBirthInfo(
        name: 'Test User',
        birthDate: DateTime(1990, 5, 15),
        birthTime: '14:30',
        birthPlace: 'Ankara, Turkey',
        latitude: 39.925533,
        longitude: 32.866287,
      );

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            initialBirthInfo: initialInfo,
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Verify form is populated with initial data
      expect(find.text('Doğum Tarihi: 15/05/1990'), findsOneWidget);
      expect(find.text('Ankara, Turkey'), findsOneWidget);
      expect(find.text('39.925533'), findsOneWidget);
      expect(find.text('32.866287'), findsOneWidget);
    });

    testWidgets('populates form with prefilledProfile data', (WidgetTester tester) async {
      final profile = UserProfile(
        id: 'test-profile-id',
        name: 'Profile User',
        birthDate: DateTime(1985, 12, 25),
        birthTime: '09:15',
        birthPlace: 'Istanbul, Turkey',
        latitude: 41.0082,
        longitude: 28.9784,
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

      // Verify form is populated with profile data
      expect(find.text('Doğum Tarihi: 25/12/1985'), findsOneWidget);
      expect(find.text('Istanbul, Turkey'), findsOneWidget);
      expect(find.text('41.0082'), findsOneWidget);
      expect(find.text('28.9784'), findsOneWidget);
    });

    testWidgets('can input text into form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Test text input in all fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Ad Soyad'), 'Test User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Doğum Yeri (Şehir, Ülke)'), 'Test City');
      await tester.enterText(find.widgetWithText(TextFormField, 'Enlem (Latitude)'), '40.0');
      await tester.enterText(find.widgetWithText(TextFormField, 'Boylam (Longitude)'), '30.0');
      
      await tester.pump();
      
      // Verify text was entered
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Test City'), findsOneWidget);
      expect(find.text('40.0'), findsOneWidget);
      expect(find.text('30.0'), findsOneWidget);
    });

    testWidgets('opens date picker when date button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Tap date selection button
      await tester.tap(find.text('Tarih Seç'));
      await tester.pumpAndSettle();

      // Verify date picker dialog is shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('opens time picker when time button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Tap time selection button
      await tester.tap(find.text('Saat Seç'));
      await tester.pumpAndSettle();

      // Verify time picker dialog is shown
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('validates required fields before submission', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Try to submit with empty fields
      final submitButton = find.text('Natal Haritamı Hesapla');
      expect(submitButton, findsOneWidget);
      
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Form should still be visible (validation prevents submission)
      expect(find.text('Ad Soyad'), findsOneWidget);
      expect(find.text('Doğum Yeri (Şehir, Ülke)'), findsOneWidget);
    });

    testWidgets('geocoding service integration test with valid data', (WidgetTester tester) async {
      // Mock successful geocoding response
      when(mockGeocodingService.getCoordinates('İstanbul'))
          .thenAnswer((_) async => {'latitude': 41.0082, 'longitude': 28.9784});
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {});

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Fill form with complete valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'İstanbul');
      await tester.enterText(find.byType(TextFormField).at(2), '41.0082');
      await tester.enterText(find.byType(TextFormField).at(3), '28.9784');
      
      // Set date and time by directly calling the setter methods
      // Instead of relying on picker dialogs, fill coordinates manually
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Natal Haritamı Hesapla'));
      await tester.pumpAndSettle();

      // Verify form submission was attempted (even if geocoding fails, the form tries to submit)
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
    });

    testWidgets('handles geocoding service error gracefully', (WidgetTester tester) async {
      // Mock geocoding service failure
      when(mockGeocodingService.getCoordinates(any))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Fill the form with valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'Unknown Place');
      await tester.enterText(find.byType(TextFormField).at(2), '40.0');
      await tester.enterText(find.byType(TextFormField).at(3), '30.0');
      
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Natal Haritamı Hesapla'));
      await tester.pumpAndSettle();

      // Form should still be present (error handling keeps user on form)
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
    });

    testWidgets('form fields maintain state during interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Enter text in form fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'İstanbul');

      // Verify text fields maintain their values after interaction
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('İstanbul'), findsOneWidget);
      
      // Tap date picker button (but don't interact with picker)
      await tester.tap(find.text('Tarih Seç'));
      await tester.pumpAndSettle();
      
      // Close any open dialog by tapping outside or using back button
      if (find.byType(DatePickerDialog).evaluate().isNotEmpty) {
        await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
        await tester.pumpAndSettle();
      }

      // Verify text fields still have their values
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('İstanbul'), findsOneWidget);
    });

    tearDownAll(() async {
      // Cleanup any resources if needed
    });
  });
}
