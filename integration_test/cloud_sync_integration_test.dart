import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/services/geocoding_service.dart';

// Mock geocoding service for consistent test results
class MockGeocodingService implements GeocodingService {
  @override
  Future<Map<String, double>?> getCoordinates(String place) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (place.toLowerCase().contains('unknown') || place.trim().isEmpty) {
      return null;
    }
    
    // Return mock coordinates for any valid-looking place
    return {
      'lat': 41.0082,
      'lon': 28.9784,
    };
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Windows Compatible Integration Tests', () {
    late MockGeocodingService mockGeocodingService;
    
    setUp(() {
      mockGeocodingService = MockGeocodingService();
    });

    testWidgets('BirthInfoScreen loads correctly', (WidgetTester tester) async {
      // Test BirthInfoScreen directly without full app initialization
      await tester.pumpWidget(
        MaterialApp(
          home: BirthInfoScreen(
            geocodingService: mockGeocodingService,
          ),
        ),
      );
      
      expect(find.byType(BirthInfoScreen), findsOneWidget);
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('submit_button')), findsOneWidget);
    });

    testWidgets('Form validation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BirthInfoScreen(
            geocodingService: mockGeocodingService,
          ),
        ),
      );
      
      // Try to submit without filling any fields
      final submitButton = find.byKey(const Key('submit_button'));
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump();
      
      // Check for validation errors
      expect(find.textContaining('adınızı'), findsOneWidget);
    });

    testWidgets('Name field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BirthInfoScreen(
            geocodingService: mockGeocodingService,
          ),
        ),
      );
      
      // Fill in the name field
      final nameField = find.byKey(const Key('name_field'));
      await tester.enterText(nameField, 'Test User');
      await tester.pump();
      
      // Verify the text was entered
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('Date field interaction works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BirthInfoScreen(
            geocodingService: mockGeocodingService,
          ),
        ),
      );
      
      // Find and tap date field
      final dateField = find.byKey(const Key('birth_date_field'));
      expect(dateField, findsOneWidget);
      
      await tester.tap(dateField);
      await tester.pump();
      
      // Just verify no crash occurred
      expect(find.byType(BirthInfoScreen), findsOneWidget);
    });

    testWidgets('Mock geocoding service works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BirthInfoScreen(
            geocodingService: mockGeocodingService,
          ),
        ),
      );
      
      // Fill in the birth place field
      final placeField = find.byKey(const Key('birth_place_field'));
      await tester.enterText(placeField, 'Istanbul');
      await tester.pump();
      
      // Verify text was entered
      expect(find.text('Istanbul'), findsOneWidget);
    });
  });
}

// Mock geocoding service for consistent test results
class MockGeocodingService implements GeocodingService {
  @override
  Future<Map<String, double>?> getCoordinates(String place) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (place.toLowerCase().contains('unknown') || place.trim().isEmpty) {
      return null;
    }
    
    // Return mock coordinates for any valid-looking place
    return {
      'lat': 41.0082,
      'lon': 28.9784,
    };
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Cross-Platform Integration Tests', () {
    late MockGeocodingService mockGeocodingService;
    
    setUp(() {
      mockGeocodingService = MockGeocodingService();
    });

    testWidgets('BirthInfoScreen loads correctly', (WidgetTester tester) async {
      // Test BirthInfoScreen directly without full app initialization
      await tester.pumpWidget(
        MaterialApp(
          home: BirthInfoScreen(
            geocodingService: mockGeocodingService,
          ),
        ),
      );
      
      expect(find.byType(BirthInfoScreen), findsOneWidget);
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('submit_button')), findsOneWidget);
    });

    testWidgets('Form validation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BirthInfoScreen(
            geocodingService: mockGeocodingService,
          ),
        ),
      );
      
      // Try to submit without filling any fields
      final submitButton = find.byKey(const Key('submit_button'));
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump();
      
      // Check for validation errors
      expect(find.textContaining('adınızı'), findsOneWidget);
    });

    testWidgets('Name field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BirthInfoScreen(
            geocodingService: mockGeocodingService,
          ),
        ),
      );
      
      // Fill in the name field
      final nameField = find.byKey(const Key('name_field'));
      await tester.enterText(nameField, 'Test User');
      await tester.pump();
      
      // Verify the text was entered
      expect(find.text('Test User'), findsOneWidget);
    });
  });
  
  group('Birth Info to Natal Chart Integration Tests', () {
    late MockGeocodingService mockGeocodingService;
    
    setUp(() {
      mockGeocodingService = MockGeocodingService();
    });

    testWidgets('Complete user flow: birth info form → natal chart screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the birth info screen
      expect(find.byType(BirthInfoScreen), findsOneWidget);
      expect(find.text('Doğum Bilgileri'), findsOneWidget);

      // Fill in the name field
      final nameField = find.byKey(const Key('name_field'));
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'Test User');
      await tester.pumpAndSettle();

      // Fill in the birth date
      final dateField = find.byKey(const Key('birth_date_field'));
      expect(dateField, findsOneWidget);
      await tester.tap(dateField);
      await tester.pumpAndSettle();
        // Select a date (assuming date picker appears)
      // Note: This might need adjustment based on your date picker implementation
      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }

      // Fill in the birth time
      final timeField = find.byKey(const Key('birth_time_field'));
      expect(timeField, findsOneWidget);
      await tester.tap(timeField);
      await tester.pumpAndSettle();
        // Select a time (assuming time picker appears)
      final timeOkButton = find.text('OK').last;
      if (timeOkButton.evaluate().isNotEmpty) {
        await tester.tap(timeOkButton);
        await tester.pumpAndSettle();
      }

      // Fill in the birth place
      final placeField = find.byKey(const Key('birth_place_field'));
      expect(placeField, findsOneWidget);
      await tester.enterText(placeField, 'İstanbul');
      await tester.pumpAndSettle();

      // Wait for geocoding to complete
      await tester.pump(const Duration(milliseconds: 500));

      // Tap the submit button
      final submitButton = find.byKey(const Key('submit_button'));
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify navigation to natal chart screen
      expect(find.byType(NatalChartScreen), findsOneWidget);
      expect(find.text('Natal Harita'), findsOneWidget);

      // Verify that birth info was passed correctly
      // This assumes the natal chart screen displays some birth info
      expect(find.textContaining('Test User'), findsOneWidget);
    });

    testWidgets('Form validation prevents navigation with incomplete data', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the birth info screen
      expect(find.byType(BirthInfoScreen), findsOneWidget);

      // Try to submit without filling any fields
      final submitButton = find.byKey(const Key('submit_button'));
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify we're still on the birth info screen (no navigation occurred)
      expect(find.byType(BirthInfoScreen), findsOneWidget);
      expect(find.byType(NatalChartScreen), findsNothing);

      // Verify validation errors are shown
      expect(find.text('Lütfen adınızı girin'), findsOneWidget);
    });

    testWidgets('Geocoding failure prevents navigation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Fill in required fields
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.pumpAndSettle();

      // Fill in date and time fields (simplified for test)
      final dateField = find.byKey(const Key('birth_date_field'));
      await tester.tap(dateField);
      await tester.pumpAndSettle();
        final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }

      final timeField = find.byKey(const Key('birth_time_field'));
      await tester.tap(timeField);
      await tester.pumpAndSettle();
        final timeOkButton = find.text('OK').last;
      if (timeOkButton.evaluate().isNotEmpty) {
        await tester.tap(timeOkButton);
        await tester.pumpAndSettle();
      }

      // Enter an unknown place that will trigger geocoding failure
      await tester.enterText(find.byKey(const Key('birth_place_field')), 'unknown place xyz');
      await tester.pumpAndSettle();

      // Wait for geocoding to complete (and fail)
      await tester.pump(const Duration(milliseconds: 500));

      // Try to submit
      await tester.tap(find.byKey(const Key('submit_button')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify we're still on the birth info screen
      expect(find.byType(BirthInfoScreen), findsOneWidget);
      expect(find.byType(NatalChartScreen), findsNothing);

      // Verify error message is shown
      expect(find.textContaining('Yer bilgisi'), findsOneWidget);
    });

    testWidgets('Back navigation from natal chart returns to birth info', (WidgetTester tester) async {
      // First complete the full flow to get to natal chart
      app.main();
      await tester.pumpAndSettle();

      // Fill form and navigate (simplified)
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
        // Fill date
      await tester.tap(find.byKey(const Key('birth_date_field')));
      await tester.pumpAndSettle();
      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }      // Fill time
      await tester.tap(find.byKey(const Key('birth_time_field')));
      await tester.pumpAndSettle();
      final timeOkButton = find.text('OK').last;
      if (timeOkButton.evaluate().isNotEmpty) {
        await tester.tap(timeOkButton);
        await tester.pumpAndSettle();
      }

      // Fill place
      await tester.enterText(find.byKey(const Key('birth_place_field')), 'İstanbul');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // Submit
      await tester.tap(find.byKey(const Key('submit_button')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify we're on natal chart screen
      expect(find.byType(NatalChartScreen), findsOneWidget);      // Navigate back
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      } else {
        // Try app bar back button
        final appBarBack = find.byTooltip('Back');
        if (appBarBack.evaluate().isNotEmpty) {
          await tester.tap(appBarBack);
          await tester.pumpAndSettle();
        }
      }

      // Verify we're back on birth info screen
      expect(find.byType(BirthInfoScreen), findsOneWidget);
      expect(find.byType(NatalChartScreen), findsNothing);

      // Verify form data is preserved
      expect(find.text('Test User'), findsOneWidget);
    });
  });
}