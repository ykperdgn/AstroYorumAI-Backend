import 'package:flutter_test/flutter_test.dart';
import 'package:astroyorumai/models/user_profile.dart';

void main() {
  group('Phase 2 Pro Feature Integration Tests', () {
    test('UserProfile serialization works correctly', () {
      // Test free user
      final freeUser = UserProfile(
        id: 'free-1',
        name: 'Free User',
        birthDate: DateTime(1995, 6, 15),
        birthTime: '14:30',
        birthPlace: 'Free City',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPro: false,
      );

      final freeUserJson = freeUser.toJson();
      final freeUserFromJson = UserProfile.fromJson(freeUserJson);
      expect(freeUserFromJson.isPro, false);
      expect(freeUserFromJson.name, 'Free User');

      // Test pro user
      final proUser = UserProfile(
        id: 'pro-1',
        name: 'Pro User',
        birthDate: DateTime(1985, 3, 22),
        birthTime: '09:15',
        birthPlace: 'Pro City',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPro: true,
      );

      final proUserJson = proUser.toJson();
      final proUserFromJson = UserProfile.fromJson(proUserJson);
      expect(proUserFromJson.isPro, true);
      expect(proUserFromJson.name, 'Pro User');
    });

    test('Pro user feature access logic', () {
      // Test free user
      final freeUser = UserProfile(
        id: 'free-user',
        name: 'Free User',
        birthDate: DateTime(1990, 1, 1),
        birthTime: '12:00',
        birthPlace: 'Test City',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPro: false,
      );

      expect(freeUser.isPro, false);

      // Test pro user
      final proUser = UserProfile(
        id: 'pro-user',
        name: 'Pro User',
        birthDate: DateTime(1990, 1, 1),
        birthTime: '12:00',
        birthPlace: 'Test City',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPro: true,
      );

      expect(proUser.isPro, true);
    });
  });
}
