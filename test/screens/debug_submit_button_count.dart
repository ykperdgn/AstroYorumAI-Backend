import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'birth_info_screen_test.mocks.dart';
import '../test_helpers.dart';

void main() {
  group('Debug Submit Button Issue', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    testWidgets('check how many submit buttons exist', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any)).thenAnswer((_) async => null);
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {});

      // Create a prefilled profile
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
      );      await tester.pumpWidget(
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

      // Debug: Check how many submit buttons exist
      final submitButtonsByKey = find.byKey(const Key('submit_button'));
      final submitButtonsByType = find.byType(ElevatedButton);
      final submitButtonsByText = find.text('Natal Haritamı Hesapla');
      
      print('=== SUBMIT BUTTON DEBUG ===');
      print('By key: ${submitButtonsByKey.evaluate().length}');
      print('By type (ElevatedButton): ${submitButtonsByType.evaluate().length}');
      print('By text: ${submitButtonsByText.evaluate().length}');
      
      // Check all ElevatedButton widgets
      for (int i = 0; i < submitButtonsByType.evaluate().length; i++) {
        final button = tester.widget<ElevatedButton>(submitButtonsByType.at(i));
        print('ElevatedButton $i: key=${button.key}, child=${button.child}');
      }
      
      // This test should always pass - we're just debugging
      expect(true, true);
    });
  });
}
