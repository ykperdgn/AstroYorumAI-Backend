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
  group('BirthInfoScreen Detailed Debug Tests', () {
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

    testWidgets('DEBUG: Why do form validation messages not appear?', (WidgetTester tester) async {
      // Use profile with date/time set to bypass early validation checks
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

      print('=== STEP 1: Initial State ===');
      final allWidgets = find.byType(Widget);
      print('Total widgets found: ${allWidgets.evaluate().length}');
      
      // Enter invalid latitude
      print('=== STEP 2: Entering Invalid Latitude ===');
      await tester.enterText(find.byType(TextFormField).at(2), '95.0'); // Invalid latitude > 90
      await tester.enterText(find.byType(TextFormField).at(3), '30.0'); // Valid longitude
      await tester.pump();

      // Try to get the Form widget and call validate directly
      print('=== STEP 3: Manual Form Validation ===');
      final formFinder = find.byType(Form);
      expect(formFinder, findsOneWidget);
      
      final formWidget = tester.widget<Form>(formFinder);
      final formState = formWidget.key as GlobalKey<FormState>;
      
      // Get the actual form state and call validate
      final isValid = formState.currentState?.validate() ?? false;
      print('Form validation result: $isValid');
      
      await tester.pump(); // Allow validation messages to appear
      
      // Check for validation messages after manual validation
      print('=== STEP 4: Checking for Validation Messages ===');
      final allTexts = find.byType(Text);
      print('All text widgets after manual validation:');
      for (int i = 0; i < allTexts.evaluate().length; i++) {
        try {
          final textWidget = tester.widget<Text>(allTexts.at(i));
          if (textWidget.data != null && 
              (textWidget.data!.contains('Enlem') || 
               textWidget.data!.contains('90') ||
               textWidget.data!.contains('-90'))) {
            print('  Found relevant text $i: "${textWidget.data}"');
            print('  Text style: ${textWidget.style}');
          }
        } catch (e) {
          // Skip widgets that can't be cast to Text
        }
      }

      // Check for any red text or error styling
      print('=== STEP 5: Looking for Error Styling ===');
      final theme = Theme.of(tester.element(find.byType(BirthInfoScreen)));
      print('Error color from theme: ${theme.colorScheme.error}');
      
      // Submit form to trigger validation via submit
      print('=== STEP 6: Submit Form Validation ===');
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump(); 
      
      print('All text widgets after form submission:');
      for (int i = 0; i < allTexts.evaluate().length; i++) {
        try {
          final textWidget = tester.widget<Text>(allTexts.at(i));
          if (textWidget.data != null && 
              (textWidget.data!.contains('Enlem') || 
               textWidget.data!.contains('90') ||
               textWidget.data!.contains('olmalıdır'))) {
            print('  Found validation text $i: "${textWidget.data}"');
          }
        } catch (e) {
          // Skip widgets that can't be cast to Text
        }
      }
    });

    testWidgets('DEBUG: Why is LoadingIndicator not showing?', (WidgetTester tester) async {
      // Mock geocoding service with delay
      when(mockGeocodingService.getCoordinates('İstanbul'))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 500)); // Longer delay
        return {'lat': 41.0082, 'lon': 28.9784};
      });
      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {});

      // Profile with birth place but no coordinates to trigger geocoding
      final profile = UserProfile(
        id: 'debug-processing',
        name: 'Test User',
        birthDate: DateTime(1985, 12, 25),
        birthTime: '14:30',
        birthPlace: 'İstanbul', // This should trigger geocoding
        latitude: null, // No coordinates
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

      print('=== STEP 1: Initial State Check ===');
      expect(find.byType(LoadingIndicator), findsNothing);
      expect(find.text('Bilgiler işleniyor...'), findsNothing);

      // Submit form - this should trigger geocoding
      print('=== STEP 2: Submitting Form ===');
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      
      await tester.tap(submitButton, warnIfMissed: false);
      print('Form submitted, checking for processing state...');
      
      // Check immediately after tap - should show processing
      await tester.pump(); 
      
      print('=== STEP 3: Checking for LoadingIndicator ===');
      final loadingFinder = find.byType(LoadingIndicator);
      final processingTextFinder = find.text('Bilgiler işleniyor...');
      
      print('LoadingIndicator found: ${loadingFinder.evaluate().length}');
      print('Processing text found: ${processingTextFinder.evaluate().length}');
      
      // Check all widgets in the tree
      print('All widgets in tree:');
      final allWidgets = find.byWidgetPredicate((widget) => true);
      for (var element in allWidgets.evaluate().take(20)) {
        print('  Widget: ${element.widget.runtimeType}');
      }
      
      // Wait a bit and check again
      await tester.pump(Duration(milliseconds: 100));
      print('After 100ms - LoadingIndicator: ${find.byType(LoadingIndicator).evaluate().length}');
      
      // Wait for completion
      await tester.pumpAndSettle();
      print('After completion - still on form: ${find.text('Doğum Bilgilerini Girin').evaluate().length}');
    });

    testWidgets('DEBUG: Direct LoadingIndicator test', (WidgetTester tester) async {
      // Test if LoadingIndicator works in isolation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(message: 'Test loading...'),
          ),
        ),
      );
      
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Test loading...'), findsOneWidget);
      print('LoadingIndicator works correctly in isolation');
    });
  });
}
