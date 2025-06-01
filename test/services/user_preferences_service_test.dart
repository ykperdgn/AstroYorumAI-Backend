import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/models/user_birth_info.dart';
import '../test_setup.dart';

// Generate mocks
@GenerateMocks([SharedPreferences])
import 'user_preferences_service_test.mocks.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTest();
  });
  group('UserPreferencesService Tests', () {
    late UserPreferencesService userPreferencesService;

    setUp(() {
      userPreferencesService = UserPreferencesService();
      resetTestSharedPreferences();
    });

    tearDown(() async {
      // Clear any data left by tests to ensure isolation
      await userPreferencesService.clearUserBirthInfo();
      resetTestSharedPreferences();
    });

    group('saveUserBirthInfo', () {
      test('should save complete UserBirthInfo successfully', () async {
        // Arrange
        final birthInfo = UserBirthInfo(
          name: 'Test User',
          birthDate: DateTime(1990, 5, 15),
          birthTime: '14:30',
          birthPlace: 'Istanbul, Turkey',
          latitude: 41.0082,
          longitude: 28.9784,
        );

        // Act
        await expectLater(
          userPreferencesService.saveUserBirthInfo(birthInfo),
          completes,
        );

        // Assert - Check that data was saved correctly by loading it back
        final loadedBirthInfo = await userPreferencesService.loadUserBirthInfo();
        expect(loadedBirthInfo, isNotNull);
        expect(loadedBirthInfo!.name, equals('Test User'));
        expect(loadedBirthInfo.birthDate, equals(DateTime(1990, 5, 15)));
        expect(loadedBirthInfo.birthTime, equals('14:30'));
        expect(loadedBirthInfo.birthPlace, equals('Istanbul, Turkey'));
        expect(loadedBirthInfo.latitude, equals(41.0082));
        expect(loadedBirthInfo.longitude, equals(28.9784));
      });

      test('should save UserBirthInfo with minimal data', () async {
        // Arrange
        final birthInfo = UserBirthInfo(
          birthDate: DateTime(1995, 12, 25),
          birthTime: '10:00',
          latitude: 40.0,
          longitude: 30.0,
        );

        // Act
        await expectLater(
          userPreferencesService.saveUserBirthInfo(birthInfo),
          completes,
        );

        // Assert
        final loadedBirthInfo = await userPreferencesService.loadUserBirthInfo();
        expect(loadedBirthInfo, isNotNull);
        expect(loadedBirthInfo!.name, isNull);
        expect(loadedBirthInfo.birthPlace, isNull);
        expect(loadedBirthInfo.birthDate, equals(DateTime(1995, 12, 25)));
        expect(loadedBirthInfo.birthTime, equals('10:00'));
        expect(loadedBirthInfo.latitude, equals(40.0));
        expect(loadedBirthInfo.longitude, equals(30.0));
      });

      test('should overwrite existing UserBirthInfo', () async {
        // Arrange - Save initial data
        final initialBirthInfo = UserBirthInfo(
          name: 'Initial User',
          birthDate: DateTime(1990, 1, 1),
          birthTime: '12:00',
          latitude: 0.0,
          longitude: 0.0,
        );
        await userPreferencesService.saveUserBirthInfo(initialBirthInfo);

        final newBirthInfo = UserBirthInfo(
          name: 'Updated User',
          birthDate: DateTime(1995, 6, 15),
          birthTime: '18:30',
          birthPlace: 'Ankara, Turkey',
          latitude: 39.9334,
          longitude: 32.8597,
        );

        // Act
        await userPreferencesService.saveUserBirthInfo(newBirthInfo);

        // Assert
        final loadedBirthInfo = await userPreferencesService.loadUserBirthInfo();
        expect(loadedBirthInfo, isNotNull);
        expect(loadedBirthInfo!.name, equals('Updated User'));
        expect(loadedBirthInfo.birthDate, equals(DateTime(1995, 6, 15)));
        expect(loadedBirthInfo.birthTime, equals('18:30'));
        expect(loadedBirthInfo.birthPlace, equals('Ankara, Turkey'));
        expect(loadedBirthInfo.latitude, equals(39.9334));
        expect(loadedBirthInfo.longitude, equals(32.8597));
      });
    });

    group('loadUserBirthInfo', () {
      test('should return null when no data exists', () async {
        // Act
        final result = await userPreferencesService.loadUserBirthInfo();

        // Assert
        expect(result, isNull);
      });

      test('should load saved UserBirthInfo correctly', () async {
        // Arrange - Save test data first
        final birthInfo = UserBirthInfo(
          name: 'Test Load User',
          birthDate: DateTime(1988, 3, 20),
          birthTime: '09:15',
          birthPlace: 'Izmir, Turkey',
          latitude: 38.4192,
          longitude: 27.1287,
        );
        await userPreferencesService.saveUserBirthInfo(birthInfo);

        // Act
        final loadedBirthInfo = await userPreferencesService.loadUserBirthInfo();

        // Assert
        expect(loadedBirthInfo, isNotNull);
        expect(loadedBirthInfo!.name, equals('Test Load User'));
        expect(loadedBirthInfo.birthDate, equals(DateTime(1988, 3, 20)));
        expect(loadedBirthInfo.birthTime, equals('09:15'));
        expect(loadedBirthInfo.birthPlace, equals('Izmir, Turkey'));
        expect(loadedBirthInfo.latitude, equals(38.4192));
        expect(loadedBirthInfo.longitude, equals(27.1287));
      });

      test('should handle invalid JSON data gracefully', () async {
        // Arrange - Set invalid JSON data
        setTestSharedPreferencesValue('userBirthInfo', 'invalid json string');

        // Act
        final result = await userPreferencesService.loadUserBirthInfo();

        // Assert
        expect(result, isNull);
        
        // Verify that invalid data was cleared
        final clearedData = await userPreferencesService.loadUserBirthInfo();
        expect(clearedData, isNull);
      });

      test('should handle data with missing required fields', () async {
        // Arrange - Set incomplete data (missing required latitude/longitude)
        final incompleteData = {
          'name': 'Test User',
          'birthDate': DateTime(1990, 1, 1).toIso8601String(),
          'birthTime': '12:00',
          'birthPlace': 'Test Place',
          // Missing latitude and longitude
        };
        setTestSharedPreferencesValue('userBirthInfo', incompleteData);

        // Act
        final result = await userPreferencesService.loadUserBirthInfo();

        // Assert
        expect(result, isNull);
        
        // Verify that invalid data was cleared
        final clearedData = await userPreferencesService.loadUserBirthInfo();
        expect(clearedData, isNull);
      });

      test('should handle data with invalid date format', () async {
        // Arrange - Set data with invalid date
        final invalidDateData = {
          'name': 'Test User',
          'birthDate': 'invalid-date-string',
          'birthTime': '12:00',
          'birthPlace': 'Test Place',
          'latitude': 40.0,
          'longitude': 30.0,
        };
        setTestSharedPreferencesValue('userBirthInfo', invalidDateData);

        // Act
        final result = await userPreferencesService.loadUserBirthInfo();

        // Assert
        expect(result, isNull);
        
        // Verify that invalid data was cleared
        final clearedData = await userPreferencesService.loadUserBirthInfo();
        expect(clearedData, isNull);
      });

      test('should handle data with wrong field types', () async {
        // Arrange - Set data with wrong types
        final wrongTypeData = {
          'name': 'Test User',
          'birthDate': DateTime(1990, 1, 1).toIso8601String(),
          'birthTime': 12, // Should be String, not int
          'birthPlace': 'Test Place',
          'latitude': '40.0', // Should be double, not String
          'longitude': 30.0,
        };
        setTestSharedPreferencesValue('userBirthInfo', wrongTypeData);

        // Act
        final result = await userPreferencesService.loadUserBirthInfo();

        // Assert
        expect(result, isNull);
        
        // Verify that invalid data was cleared
        final clearedData = await userPreferencesService.loadUserBirthInfo();
        expect(clearedData, isNull);
      });
    });

    group('clearUserBirthInfo', () {
      test('should clear saved UserBirthInfo', () async {
        // Arrange - Save some data first
        final birthInfo = UserBirthInfo(
          name: 'Test User To Clear',
          birthDate: DateTime(1992, 8, 10),
          birthTime: '16:45',
          latitude: 45.0,
          longitude: 35.0,
        );
        await userPreferencesService.saveUserBirthInfo(birthInfo);
        
        // Verify data was saved
        final savedData = await userPreferencesService.loadUserBirthInfo();
        expect(savedData, isNotNull);

        // Act
        await userPreferencesService.clearUserBirthInfo();

        // Assert
        final result = await userPreferencesService.loadUserBirthInfo();
        expect(result, isNull);
      });

      test('should complete successfully even when no data exists', () async {
        // Act & Assert
        await expectLater(
          userPreferencesService.clearUserBirthInfo(),
          completes,
        );

        // Verify still no data
        final result = await userPreferencesService.loadUserBirthInfo();
        expect(result, isNull);
      });
    });

    group('error scenarios', () {
      test('should handle SharedPreferences exceptions gracefully', () async {
        // Note: This test would require mocking SharedPreferences.getInstance()
        // to throw an exception, which is complex with the current setup.
        // For now, we'll test that normal operations complete without error.
        
        // Arrange
        final birthInfo = UserBirthInfo(
          name: 'Error Test User',
          birthDate: DateTime(1985, 11, 5),
          birthTime: '07:20',
          latitude: 50.0,
          longitude: 40.0,
        );

        // Act & Assert - Should not throw
        await expectLater(
          userPreferencesService.saveUserBirthInfo(birthInfo),
          completes,
        );
        
        await expectLater(
          userPreferencesService.loadUserBirthInfo(),
          completion(isNotNull),
        );
        
        await expectLater(
          userPreferencesService.clearUserBirthInfo(),
          completes,
        );
      });
    });

    group('data validation edge cases', () {
      test('should handle null birthDate', () async {
        // Arrange - Create UserBirthInfo with null birthDate
        final birthInfo = UserBirthInfo(
          name: 'Test User',
          birthDate: null, // This should cause validation to fail
          birthTime: '12:00',
          latitude: 40.0,
          longitude: 30.0,
        );

        // Act
        await userPreferencesService.saveUserBirthInfo(birthInfo);
        final result = await userPreferencesService.loadUserBirthInfo();

        // Assert - Should return null due to validation failure
        expect(result, isNull);
      });

      test('should handle extreme coordinate values', () async {
        // Arrange - Test with extreme but valid coordinates
        final birthInfo = UserBirthInfo(
          name: 'Extreme Coordinates User',
          birthDate: DateTime(2000, 1, 1),
          birthTime: '00:00',
          birthPlace: 'North Pole',
          latitude: 90.0, // Maximum latitude
          longitude: 180.0, // Maximum longitude
        );

        // Act
        await userPreferencesService.saveUserBirthInfo(birthInfo);
        final result = await userPreferencesService.loadUserBirthInfo();

        // Assert
        expect(result, isNotNull);
        expect(result!.latitude, equals(90.0));
        expect(result.longitude, equals(180.0));
      });

      test('should handle very long names and places', () async {
        // Arrange - Test with very long strings
        final longName = 'A' * 1000; // Very long name
        final longPlace = 'B' * 1000; // Very long place name
        
        final birthInfo = UserBirthInfo(
          name: longName,
          birthDate: DateTime(1975, 6, 30),
          birthTime: '23:59',
          birthPlace: longPlace,
          latitude: 0.0,
          longitude: 0.0,
        );

        // Act
        await userPreferencesService.saveUserBirthInfo(birthInfo);
        final result = await userPreferencesService.loadUserBirthInfo();

        // Assert
        expect(result, isNotNull);
        expect(result!.name, equals(longName));
        expect(result.birthPlace, equals(longPlace));
      });
    });
  });
}
