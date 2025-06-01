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
    });    testWidgets('shows required form elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Verify all required form elements are present
      expect(find.text('Doğum Tarihi Seçilmedi'), findsOneWidget);
      expect(find.text('Doğum Saati Seçilmedi'), findsOneWidget);
      
      // Check that fields are accessible
      final nameField = find.widgetWithText(TextFormField, 'Ad Soyad');
      final placeField = find.widgetWithText(TextFormField, 'Doğum Yeri (Şehir, Ülke)');
      final latField = find.widgetWithText(TextFormField, 'Enlem (Latitude)');
      final lonField = find.widgetWithText(TextFormField, 'Boylam (Longitude)');
      
      expect(nameField, findsOneWidget);
      expect(placeField, findsOneWidget);
      expect(latField, findsOneWidget);
      expect(lonField, findsOneWidget);
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

    tearDownAll(() async {
      // Cleanup any resources if needed
    });
  });
}
