import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroyorumai/services/profile_management_service.dart';
import '../test_setup.dart';
import '../helpers/firebase_test_helper.dart';

// Generate mocks

void main() {
  setUpAll(() async {
    // Firebase test mock'larını ayarla
    setupFirebaseTestMocks();
    await setupFirebaseForTest();
  });

  group('ProfileManagementService Tests', () {
    late ProfileManagementService service;

    setUp(() async {
      resetTestSharedPreferences();
      service = await ProfileManagementService.getInstance();
    });

    tearDown(() async {
      // Clear all profiles after each test to ensure isolation
      await service.clearAllProfiles();
    });

    group('Profile CRUD Operations', () {
      test('should create new profile with unique ID', () {
        // Act
        final profile = service.createNewProfile(
          name: 'Test User',
          birthDate: DateTime(1990, 5, 15),
          birthTime: '14:30',
          birthPlace: 'Istanbul, Turkey',
          latitude: 41.0082,
          longitude: 28.9784,
        );

        // Assert
        expect(profile.id, isNotEmpty);
        expect(profile.name, equals('Test User'));
        expect(profile.birthDate, equals(DateTime(1990, 5, 15)));
        expect(profile.birthTime, equals('14:30'));
        expect(profile.birthPlace, equals('Istanbul, Turkey'));
        expect(profile.latitude, equals(41.0082));
        expect(profile.longitude, equals(28.9784));
        expect(profile.createdAt, isNotNull);
        expect(profile.updatedAt, isNotNull);
        expect(profile.isDefault, isFalse);
      });

      test('should save profile successfully', () async {
        // Arrange
        final profile = service.createNewProfile(
          name: 'Test User',
          birthDate: DateTime(1990, 5, 15),
          birthTime: '14:30',
          birthPlace: 'Istanbul, Turkey',
          latitude: 41.0082,
          longitude: 28.9784,
        );

        // Act
        final result = await service.saveProfile(profile);

        // Assert
        expect(result, isTrue);
        
        // Verify profile was saved by retrieving it
        final profiles = await service.getAllProfiles();
        expect(profiles, hasLength(1));
        expect(profiles.first.name, equals('Test User'));
      });

      test('should set first profile as default and active', () async {
        // Arrange
        final profile = service.createNewProfile(
          name: 'First User',
          birthDate: DateTime(1990, 5, 15),
        );

        // Act
        await service.saveProfile(profile);

        // Assert
        final profiles = await service.getAllProfiles();
        expect(profiles.first.isDefault, isTrue);
        
        final activeProfile = await service.getActiveProfile();
        expect(activeProfile, isNotNull);
        expect(activeProfile!.id, equals(profile.id));
      });

      test('should update existing profile', () async {
        // Arrange
        final profile = service.createNewProfile(
          name: 'Test User',
          birthDate: DateTime(1990, 5, 15),
        );
        await service.saveProfile(profile);

        // Wait a bit to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 10));

        // Act - Save profile with same ID but different data
        final updatedProfile = profile.copyWith(
          name: 'Updated User',
          birthPlace: 'Ankara, Turkey',
        );
        final result = await service.saveProfile(updatedProfile);

        // Assert
        expect(result, isTrue);
        
        final profiles = await service.getAllProfiles();
        expect(profiles, hasLength(1));
        expect(profiles.first.name, equals('Updated User'));
        expect(profiles.first.birthPlace, equals('Ankara, Turkey'));
        expect(profiles.first.updatedAt.isAfter(profile.updatedAt), isTrue);
      });

      test('should retrieve all profiles', () async {
        // Arrange
        final profile1 = service.createNewProfile(
          name: 'User 1',
          birthDate: DateTime(1990, 5, 15),
        );
        final profile2 = service.createNewProfile(
          name: 'User 2',
          birthDate: DateTime(1985, 10, 20),
        );

        await service.saveProfile(profile1);
        await service.saveProfile(profile2);

        // Act
        final profiles = await service.getAllProfiles();

        // Assert
        expect(profiles, hasLength(2));
        expect(profiles.map((p) => p.name), containsAll(['User 1', 'User 2']));
      });

      test('should return empty list when no profiles exist', () async {
        // Act
        final profiles = await service.getAllProfiles();

        // Assert
        expect(profiles, isEmpty);
      });
    });

    group('Profile Deletion', () {
      test('should delete profile successfully', () async {
        // Arrange
        final profile = service.createNewProfile(
          name: 'Test User',
          birthDate: DateTime(1990, 5, 15),
        );
        await service.saveProfile(profile);

        // Act
        final result = await service.deleteProfile(profile.id);

        // Assert
        expect(result, isTrue);
        
        final profiles = await service.getAllProfiles();
        expect(profiles, isEmpty);
      });

      test('should return false when deleting non-existent profile', () async {
        // Act
        final result = await service.deleteProfile('non-existent-id');

        // Assert
        expect(result, isFalse);
      });

      test('should set new active profile when deleting active profile', () async {
        // Arrange
        final profile1 = service.createNewProfile(
          name: 'User 1',
          birthDate: DateTime(1990, 5, 15),
        );
        final profile2 = service.createNewProfile(
          name: 'User 2',
          birthDate: DateTime(1985, 10, 20),
        );

        await service.saveProfile(profile1);
        await service.saveProfile(profile2);
        
        // Set profile1 as active
        await service.setActiveProfile(profile1.id);

        // Act - Delete active profile
        final result = await service.deleteProfile(profile1.id);

        // Assert
        expect(result, isTrue);
        
        final activeProfile = await service.getActiveProfile();
        expect(activeProfile, isNotNull);
        expect(activeProfile!.id, equals(profile2.id));
        expect(activeProfile.isDefault, isTrue);
      });
    });

    group('Active Profile Management', () {
      test('should set and get active profile', () async {
        // Arrange
        final profile1 = service.createNewProfile(
          name: 'User 1',
          birthDate: DateTime(1990, 5, 15),
        );
        final profile2 = service.createNewProfile(
          name: 'User 2',
          birthDate: DateTime(1985, 10, 20),
        );

        await service.saveProfile(profile1);
        await service.saveProfile(profile2);

        // Act
        final result = await service.setActiveProfile(profile2.id);

        // Assert
        expect(result, isTrue);
        
        final activeProfile = await service.getActiveProfile();
        expect(activeProfile, isNotNull);
        expect(activeProfile!.id, equals(profile2.id));
        expect(activeProfile.isDefault, isTrue);
        
        // Check that profile1 is no longer default
        final profiles = await service.getAllProfiles();
        final profile1Updated = profiles.firstWhere((p) => p.id == profile1.id);
        expect(profile1Updated.isDefault, isFalse);
      });

      test('should return null when no active profile is set', () async {
        // Act
        final activeProfile = await service.getActiveProfile();

        // Assert
        expect(activeProfile, isNull);
      });

      test('should return null when active profile ID does not exist', () async {
        // Arrange - Set a non-existent profile as active
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('active_profile_id', 'non-existent-id');

        // Act
        final activeProfile = await service.getActiveProfile();

        // Assert
        expect(activeProfile, isNull);
      });

      test('should get active profile ID', () async {
        // Arrange
        final profile = service.createNewProfile(
          name: 'Test User',
          birthDate: DateTime(1990, 5, 15),
        );
        await service.saveProfile(profile);

        // Act
        final activeId = await service.getActiveProfileId();

        // Assert
        expect(activeId, equals(profile.id));
      });
    });

    group('Profile Import and Creation', () {
      test('should import profile from birth info', () async {
        // Act
        final profile = await service.importFromBirthInfo(
          name: 'Imported User',
          birthDate: DateTime(1992, 8, 10),
          birthTime: '16:45',
          birthPlace: 'Izmir, Turkey',
          latitude: 38.4192,
          longitude: 27.1287,
        );

        // Assert
        expect(profile, isNotNull);
        expect(profile!.name, equals('Imported User'));
        expect(profile.birthDate, equals(DateTime(1992, 8, 10)));
        expect(profile.birthTime, equals('16:45'));
        expect(profile.birthPlace, equals('Izmir, Turkey'));
        expect(profile.latitude, equals(38.4192));
        expect(profile.longitude, equals(27.1287));
        
        // Verify it was saved
        final profiles = await service.getAllProfiles();
        expect(profiles, hasLength(1));
        expect(profiles.first.id, equals(profile.id));
      });

      test('should create profile with minimal data', () {
        // Act
        final profile = service.createNewProfile(
          name: 'Minimal User',
          birthDate: DateTime(1995, 12, 25),
        );

        // Assert
        expect(profile.name, equals('Minimal User'));
        expect(profile.birthDate, equals(DateTime(1995, 12, 25)));
        expect(profile.birthTime, isNull);
        expect(profile.birthPlace, isNull);
        expect(profile.latitude, isNull);
        expect(profile.longitude, isNull);
        expect(profile.id, isNotEmpty);
        expect(profile.createdAt, isNotNull);
        expect(profile.updatedAt, isNotNull);
      });
    });

    group('Profile Search and Count', () {
      test('should search profiles by name', () async {
        // Arrange
        final profile1 = service.createNewProfile(
          name: 'Alice Johnson',
          birthDate: DateTime(1990, 5, 15),
          birthPlace: 'New York',
        );
        final profile2 = service.createNewProfile(
          name: 'Bob Smith',
          birthDate: DateTime(1985, 10, 20),
          birthPlace: 'London',
        );
        final profile3 = service.createNewProfile(
          name: 'Alice Cooper',
          birthDate: DateTime(1992, 3, 8),
          birthPlace: 'Paris',
        );

        await service.saveProfile(profile1);
        await service.saveProfile(profile2);
        await service.saveProfile(profile3);

        // Act
        final results = await service.searchProfiles('Alice');

        // Assert
        expect(results, hasLength(2));
        expect(results.map((p) => p.name), containsAll(['Alice Johnson', 'Alice Cooper']));
      });

      test('should search profiles by birth place', () async {
        // Arrange
        final profile1 = service.createNewProfile(
          name: 'User 1',
          birthDate: DateTime(1990, 5, 15),
          birthPlace: 'Istanbul, Turkey',
        );
        final profile2 = service.createNewProfile(
          name: 'User 2',
          birthDate: DateTime(1985, 10, 20),
          birthPlace: 'Ankara, Turkey',
        );

        await service.saveProfile(profile1);
        await service.saveProfile(profile2);

        // Act
        final results = await service.searchProfiles('Turkey');

        // Assert
        expect(results, hasLength(2));
      });

      test('should return empty list for no search matches', () async {
        // Arrange
        final profile = service.createNewProfile(
          name: 'Test User',
          birthDate: DateTime(1990, 5, 15),
        );
        await service.saveProfile(profile);

        // Act
        final results = await service.searchProfiles('NonExistent');

        // Assert
        expect(results, isEmpty);
      });

      test('should get correct profile count', () async {
        // Arrange
        expect(await service.getProfileCount(), equals(0));

        final profile1 = service.createNewProfile(
          name: 'User 1',
          birthDate: DateTime(1990, 5, 15),
        );
        await service.saveProfile(profile1);

        expect(await service.getProfileCount(), equals(1));

        final profile2 = service.createNewProfile(
          name: 'User 2',
          birthDate: DateTime(1985, 10, 20),
        );
        await service.saveProfile(profile2);

        // Act & Assert
        expect(await service.getProfileCount(), equals(2));
      });
    });

    group('Data Management', () {
      test('should clear all profiles', () async {
        // Arrange
        final profile1 = service.createNewProfile(
          name: 'User 1',
          birthDate: DateTime(1990, 5, 15),
        );
        final profile2 = service.createNewProfile(
          name: 'User 2',
          birthDate: DateTime(1985, 10, 20),
        );

        await service.saveProfile(profile1);
        await service.saveProfile(profile2);

        // Act
        final result = await service.clearAllProfiles();

        // Assert
        expect(result, isTrue);
        
        final profiles = await service.getAllProfiles();
        expect(profiles, isEmpty);
        
        final activeProfile = await service.getActiveProfile();
        expect(activeProfile, isNull);
        
        final count = await service.getProfileCount();
        expect(count, equals(0));
      });
    });

    group('Error Handling', () {
      test('should handle JSON serialization errors gracefully', () async {
        // This test ensures the service can handle various edge cases
        // and doesn't crash on unexpected data
        
        // Create profile with edge case data
        final profile = service.createNewProfile(
          name: 'Test"User\'With"Special\\Characters',
          birthDate: DateTime(1990, 5, 15),
          birthPlace: 'City with émöjî 🌟',
        );

        // Act & Assert
        final result = await service.saveProfile(profile);
        expect(result, isTrue);
        
        final profiles = await service.getAllProfiles();
        expect(profiles, hasLength(1));
        expect(profiles.first.name, equals('Test"User\'With"Special\\Characters'));
        expect(profiles.first.birthPlace, equals('City with émöjî 🌟'));
      });

      test('should handle extreme coordinate values', () async {
        // Arrange
        final profile = service.createNewProfile(
          name: 'Extreme Coordinates User',
          birthDate: DateTime(2000, 1, 1),
          latitude: 90.0, // North Pole
          longitude: 180.0, // International Date Line
        );

        // Act
        final result = await service.saveProfile(profile);

        // Assert
        expect(result, isTrue);
        
        final profiles = await service.getAllProfiles();
        expect(profiles.first.latitude, equals(90.0));
        expect(profiles.first.longitude, equals(180.0));
      });

      test('should handle very long names and places', () async {
        // Arrange
        final longName = 'A' * 1000; // Very long name
        final longPlace = 'B' * 1000; // Very long place name
        
        final profile = service.createNewProfile(
          name: longName,
          birthDate: DateTime(1975, 6, 30),
          birthPlace: longPlace,
        );

        // Act
        final result = await service.saveProfile(profile);

        // Assert
        expect(result, isTrue);
          final profiles = await service.getAllProfiles();
        expect(profiles.first.name, equals(longName));
        expect(profiles.first.birthPlace, equals(longPlace));
      });
    });

    tearDownAll(() {
      // Firebase test mock'larını temizle
      tearDownFirebaseTestMocks();
    });
  });
}
