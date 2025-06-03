import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:astroyorumai/screens/birth_info_screen.dart';
import '../test/test_helpers.dart'; // Import shared test helpers

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Windows Compatible Integration Tests', () {
    late SharedMockGeocodingService mockGeocodingService;
    
    setUp(() {
      mockGeocodingService = SharedMockGeocodingService();
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

    testWidgets('Geocoding service returns null for unknown places', (WidgetTester tester) async {
      // Test the mock service directly
      final result = await mockGeocodingService.getCoordinates('unknown place');
      expect(result, isNull);
      
      final validResult = await mockGeocodingService.getCoordinates('Istanbul');
      expect(validResult, isNotNull);
      expect(validResult!['lat'], 41.0082);
      expect(validResult['lon'], 28.9784);
    });
  });
}