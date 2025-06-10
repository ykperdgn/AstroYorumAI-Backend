import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'screens/birth_info_screen_test.mocks.dart';
import 'test_helpers.dart';

void main() {
  group('Debug Direct onPressed Call Tests', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    testWidgets('compare tap vs direct onPressed call',
        (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);

      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {
        saveWasCalled = true;
      });

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
        createTestApp(
          BirthInfoScreen(
            prefilledProfile: profile,
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
            alwaysAutoValidate: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find submit button
      final submitButtonFinder = find.byKey(const Key('submit_button'));
      expect(submitButtonFinder, findsOneWidget);

      final ElevatedButton submitButton =
          tester.widget<ElevatedButton>(submitButtonFinder);

      // Test 1: Try tester.tap() (we know this fails)
      await tester.tap(submitButtonFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Reset the flag
      saveWasCalled = false;

      // Test 2: Call onPressed directly (this should work)

      try {
        if (submitButton.onPressed != null) {
          await tester.runAsync(() async {
            await (submitButton.onPressed as Future<void> Function())();
          });
          await tester.pumpAndSettle();
        }
      } catch (e) {}

      // The test should pass if direct call works
      expect(saveWasCalled, isTrue,
          reason: 'Direct onPressed call should trigger save');
    });
  });
}
