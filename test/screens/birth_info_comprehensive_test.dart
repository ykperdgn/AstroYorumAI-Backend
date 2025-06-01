// Comprehensive test with all required fields to test coordinate validation
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/services/geocoding_service.dart';
import 'package:astroyorumai/widgets/loading_indicator.dart';
import 'package:astroyorumai/models/user_birth_info.dart';

import 'birth_info_screen_test.mocks.dart';

void main() {
  group('BirthInfoScreen Comprehensive Validation Tests', () {
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
    }    // Helper method to create screen with pre-set date/time
    Widget createScreenWithDateTime({
      UserBirthInfo? Function(UserBirthInfo)? onComplete,
    }) {
      return BirthInfoScreen(
        preferencesService: mockPreferencesService,
        geocodingService: mockGeocodingService,
        onComplete: onComplete,
        initialBirthInfo: UserBirthInfo(
          name: '',
          birthDate: DateTime(2000, 1, 1),
          birthTime: '12:00',
          birthPlace: null,
          latitude: null,
          longitude: null,
        ),
      );
    }

    // Helper method to set name and coordinate fields
    Future<void> setNameAndCoordinates(WidgetTester tester, {
      String? name,
      String? latitude,
      String? longitude,
    }) async {
      if (name != null) {
        await tester.enterText(find.byType(TextFormField).at(0), name);
      }
      if (latitude != null) {
        await tester.enterText(find.byType(TextFormField).at(2), latitude);
      }
      if (longitude != null) {
        await tester.enterText(find.byType(TextFormField).at(3), longitude);
      }
      await tester.pump();
    }    testWidgets('Should show validation errors for invalid coordinates with all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          createScreenWithDateTime(),
        ),
      );

      // Set name and invalid coordinates
      await setNameAndCoordinates(tester, 
        name: 'Test User',
        latitude: '95.0', // Invalid
        longitude: '190.0', // Invalid
      );

      print('=== BEFORE SUBMIT (all fields set) ===');
      
      // Debug: Check what values are actually in the text fields
      final nameField = find.byType(TextFormField).at(0);
      final latField = find.byType(TextFormField).at(2);
      final lonField = find.byType(TextFormField).at(3);
      
      print('Name field value: "${tester.widget<TextFormField>(nameField).controller?.text}"');
      print('Latitude field value: "${tester.widget<TextFormField>(latField).controller?.text}"');
      print('Longitude field value: "${tester.widget<TextFormField>(lonField).controller?.text}"');
        // Submit form - try a more direct approach
      final submitButton = find.text('Natal Haritamı Hesapla');
      print('Submit button found: ${submitButton.evaluate().length}');
      
      // Check if button is enabled by looking at the ElevatedButton widget
      final buttonWidget = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      print('Button onPressed is null (disabled): ${buttonWidget.onPressed == null}');
      
      // Try to scroll to make button visible first
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pump();
      
      // Now tap the button
      print('Attempting to tap submit button...');
      await tester.tap(submitButton);
      await tester.pump(); // Initial pump
      await tester.pump(Duration(milliseconds: 100)); // Allow validation
      await tester.pump(); // Additional pump for UI updates
      
      print('=== AFTER SUBMIT (all fields set) ===');
      print('All text widgets:');
      for (var element in find.byType(Text).evaluate()) {
        final widget = element.widget as Text;
        if (widget.data != null) {
          print('  Text: "${widget.data}"');
        }
      }
        // Check for specific validation messages
      expect(find.text('Enlem -90 ile 90 arasında olmalıdır'), findsOneWidget);
      expect(find.text('Boylam -180 ile 180 arasında olmalıdır'), findsOneWidget);
      
      print('SUCCESS: Both validation error messages found!');
    });    testWidgets('Should show LoadingIndicator during geocoding', (WidgetTester tester) async {
      // Mock geocoding service to return coordinates after delay
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return {'lat': 41.0, 'lon': 29.0};
      });

      await tester.pumpWidget(
        createTestWidget(
          createScreenWithDateTime(),
        ),
      );

      // Set required fields but use birth place instead of coordinates
      await setNameAndCoordinates(tester, name: 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'Istanbul, Turkey'); // Birth place      // Submit form to trigger geocoding
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump(); // Initial pump
      
      print('=== DURING GEOCODING ===');
      print('LoadingIndicator found: ${find.byType(LoadingIndicator).evaluate().length}');
      
      // LoadingIndicator should be visible during geocoding
      expect(find.byType(LoadingIndicator), findsOneWidget);
      
      // Complete the geocoding
      await tester.pump(Duration(milliseconds: 200));
      
      print('=== AFTER GEOCODING ===');
      print('LoadingIndicator found: ${find.byType(LoadingIndicator).evaluate().length}');
    });    testWidgets('Should trigger onComplete callback with valid data', (WidgetTester tester) async {
      UserBirthInfo? capturedBirthInfo;
      
      await tester.pumpWidget(
        createTestWidget(
          createScreenWithDateTime(
            onComplete: (birthInfo) {
              capturedBirthInfo = birthInfo;
            },
          ),
        ),
      );

      // Set name and valid coordinates
      await setNameAndCoordinates(tester, 
        name: 'Test User',
        latitude: '41.0', // Valid
        longitude: '29.0', // Valid
      );      // Submit form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.dragUntilVisible(
        submitButton,
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      
      print('=== AFTER VALID SUBMIT ===');
      print('onComplete callback triggered: ${capturedBirthInfo != null}');
      if (capturedBirthInfo != null) {
        print('Captured birth info name: ${capturedBirthInfo!.name}');
        print('Captured birth info latitude: ${capturedBirthInfo!.latitude}');
        print('Captured birth info longitude: ${capturedBirthInfo!.longitude}');
      }
      
      // Verify the callback was triggered with correct data
      expect(capturedBirthInfo, isNotNull);
      expect(capturedBirthInfo!.name, equals('Test User'));
      expect(capturedBirthInfo!.latitude, equals(41.0));
      expect(capturedBirthInfo!.longitude, equals(29.0));
    });
  });
}
