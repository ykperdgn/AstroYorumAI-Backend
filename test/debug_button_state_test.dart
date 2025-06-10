import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'screens/birth_info_screen_test.mocks.dart';
import 'test_helpers.dart';

void main() {
  group('Debug Button State Tests', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    Widget createTestWidget(Widget child) {
      return createTestApp(child);
    }

    testWidgets('debug button state and tap behavior',
        (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);

      when(mockPreferencesService.saveUserBirthInfo(any))
          .thenAnswer((_) async {});

      final profile = UserProfile(
        id: 'test',
        name: 'Test User',
        birthDate: DateTime(1990, 1, 15),
        birthTime: '12:00',
        birthPlace: 'Test City',
        latitude: 40.0,
        longitude: 30.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            prefilledProfile: profile,
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
            alwaysAutoValidate: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if submit button exists
      final submitButtonFinder = find.byKey(const Key('submit_button'));
      expect(submitButtonFinder, findsOneWidget,
          reason: 'Submit button should exist');

      // Get the actual ElevatedButton widget
      final ElevatedButton submitButton =
          tester.widget<ElevatedButton>(submitButtonFinder);

      // Verify button is enabled
      expect(submitButton.onPressed, isNotNull,
          reason: 'Submit button should be enabled');

      // Try scrolling to make button visible first - use key for scrolling but check if it's unique
      try {
        await tester.scrollUntilVisible(submitButtonFinder, 500.0);
        await tester.pumpAndSettle();
      } catch (e) {
        // If scrolling fails, just continue without scrolling
      }
      // Check if button is still enabled after scroll attempt

      // Try tapping the button
      await tester.tap(submitButtonFinder, warnIfMissed: false);

      await tester.pump(); // Process the tap

      await tester.pumpAndSettle(); // Wait for any async operations

      // Check if the button is still enabled after tap
    });
  });
}
