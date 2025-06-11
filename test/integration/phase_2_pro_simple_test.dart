import 'package:flutter_test/flutter_test.dart';
import 'package:astroyorumai/models/user_profile.dart';

void main() {
  group('Phase 2 Pro Simple Tests', () {
    test('should create and serialize UserProfile with Pro features', () {
      final profile = UserProfile(
        id: 'test_id',
        name: 'Test User',
        birthDate: DateTime(1990, 5, 15),
        birthTime: '14:30',
        birthPlace: 'Istanbul',
        latitude: 41.0082,
        longitude: 28.9784,
        isPro: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.isPro, isTrue);
      expect(profile.name, equals('Test User'));
      expect(profile.birthPlace, equals('Istanbul'));

      // Test JSON serialization
      final json = profile.toJson();
      expect(json['isPro'], isTrue);
      expect(json['name'], equals('Test User'));

      // Test JSON deserialization
      final fromJson = UserProfile.fromJson(json);
      expect(fromJson.isPro, isTrue);
      expect(fromJson.name, equals('Test User'));
    });

    test('should handle free user limitations', () {
      final freeUser = UserProfile(
        id: 'free_user',
        name: 'Free User',
        birthDate: DateTime(1990, 5, 15),
        birthTime: '14:30',
        birthPlace: 'Istanbul',
        isPro: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(freeUser.isPro, isFalse);

      // Test JSON serialization for free user
      final json = freeUser.toJson();
      expect(json['isPro'], isFalse);
    });
  });
}
