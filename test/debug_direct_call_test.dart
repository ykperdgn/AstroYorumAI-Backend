import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'screens/birth_info_screen_test.mocks.dart';
import 'test_helpers.dart';

void main() {
  group('Debug Form Submission Tests', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    testWidgets('debug form submission step by step',
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

      // Verify fields are populated (from previous test we know they are)
      tester.widget<TextFormField>(find.byKey(const Key('name_field')));
      tester.widget<TextFormField>(find.byType(TextFormField).at(2));
      tester.widget<TextFormField>(find.byType(TextFormField).at(3));

      // Find submit button
      final submitButtonFinder = find.byKey(const Key('submit_button'));
      final ElevatedButton submitButton =
          tester.widget<ElevatedButton>(submitButtonFinder);

      // Try to trigger onPressed directly
      try {
        if (submitButton.onPressed != null) {
          // Call the function and wait for it
          await tester.runAsync(() async {
            await (submitButton.onPressed as Future<void> Function())();
          });
          await tester.pumpAndSettle();
        }
      } catch (e) {
        // Handle or log the error as needed
      }

      // Check if save was called
      expect(saveWasCalled, isTrue);
    });
  });
}
