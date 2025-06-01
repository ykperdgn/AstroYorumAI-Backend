import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
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
  group('BirthInfoScreen Validation Fix Test', () {
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

    testWidgets('validates latitude field correctly - FIXED', (WidgetTester tester) async {
      // Use the same setup as debug test which worked
      final profile = UserProfile(
        id: 'debug-validation',
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

      // Enter invalid latitude
      await tester.enterText(find.byType(TextFormField).at(2), '95.0'); // Invalid latitude > 90
      await tester.enterText(find.byType(TextFormField).at(3), '30.0'); // Valid longitude
      await tester.pump();

      // Try to get the Form widget and call validate directly like in debug test
      final formFinder = find.byType(Form);
      expect(formFinder, findsOneWidget);
      
      final formWidget = tester.widget<Form>(formFinder);
      final formState = formWidget.key as GlobalKey<FormState>;
      
      // Get the actual form state and call validate
      final isValid = formState.currentState?.validate() ?? false;
      expect(isValid, isFalse); // Should be false due to invalid latitude
      
      await tester.pump(); // Allow validation messages to appear
      
      // Now check for the validation message
      expect(find.text('Enlem -90 ile 90 arasında olmalıdır'), findsOneWidget);
    });

    testWidgets('validates longitude field correctly - FIXED', (WidgetTester tester) async {
      final profile = UserProfile(
        id: 'debug-validation-lon',
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

      // Enter invalid longitude
      await tester.enterText(find.byType(TextFormField).at(2), '40.0'); // Valid latitude
      await tester.enterText(find.byType(TextFormField).at(3), '200.0'); // Invalid longitude > 180
      await tester.pump();

      // Manually trigger form validation
      final formFinder = find.byType(Form);
      final formWidget = tester.widget<Form>(formFinder);
      final formState = formWidget.key as GlobalKey<FormState>;
      
      final isValid = formState.currentState?.validate() ?? false;
      expect(isValid, isFalse); // Should be false due to invalid longitude
      
      await tester.pump();
      
      expect(find.text('Boylam -180 ile 180 arasında olmalıdır'), findsOneWidget);
    });

    testWidgets('displays processing state when form is submitted - FIXED', (WidgetTester tester) async {
      // Mock geocoding with proper delay and keys
      when(mockGeocodingService.getCoordinates('İstanbul'))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 300));
        return {'lat': 41.0082, 'lon': 28.9784};
      });
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {});

      final profile = UserProfile(
        id: 'debug-processing',
        name: 'Test User',
        birthDate: DateTime(1985, 12, 25),
        birthTime: '14:30',
        birthPlace: null, // No birth place initially
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

      // Submit form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump(); // Process the tap
      
      // Check for loading state immediately
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Bilgiler işleniyor...'), findsOneWidget);
      
      // Wait for completion
      await tester.pumpAndSettle();
    });
  });
}
