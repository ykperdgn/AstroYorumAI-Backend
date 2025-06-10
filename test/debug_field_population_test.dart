import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'screens/birth_info_screen_test.mocks.dart';
import 'test_helpers.dart';

void main() {
  group('Debug Field Population Tests', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    testWidgets('debug field population from profile',
        (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any))
          .thenAnswer((_) async => null);
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {
        // print('=== MOCK SAVE CALLED ===');
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

      // print('=== CHECKING FIELD POPULATION ===');

      // Check name field
      final nameField = find.byKey(const Key('name_field'));
      expect(nameField, findsOneWidget);

      // Check birth place field
      final birthPlaceField = find.byKey(const Key('birth_place_field'));
      expect(birthPlaceField, findsOneWidget);

      // Check if date and time text are visible
      expect(find.text('Doğum Tarihi: 15/01/1990'), findsOneWidget);
      expect(find.text('Doğum Saati: 12:00'), findsOneWidget);

      // print('=== FIELD POPULATION CHECK COMPLETE ===');
      // print('Name: "${nameController?.text}"');
      // print('Latitude: "${latitudeController?.text}"');
      // print('Longitude: "${longitudeController?.text}"');
      // print('Birth Place: "${birthPlaceController?.text}"');
    });
  });
}
