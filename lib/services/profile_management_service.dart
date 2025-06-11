import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'dart:developer' as log;

class ProfileManagementService {
  final SharedPreferences prefs;

  ProfileManagementService(this.prefs);
  // Static instance for convenience
  static ProfileManagementService? _instance;
  static Future<ProfileManagementService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = ProfileManagementService(prefs);
    }
    return _instance!;
  }

  // Instance methods
  // Get active profile
  Future<UserProfile?> getActiveProfile() async {
    final activeId = await getActiveProfileId();
    if (activeId == null) return null;

    final profiles = await getAllProfiles();
    try {
      return profiles.firstWhere((profile) => profile.id == activeId);
    } catch (e) {
      return null;
    }
  }

  // Get active profile ID
  Future<String?> getActiveProfileId() async {
    return prefs.getString('active_profile_id');
  }

  // Get all profiles
  Future<List<UserProfile>> getAllProfiles() async {
    final profilesJson = prefs.getString('user_profiles');

    if (profilesJson == null) {
      return [];
    }

    final List<dynamic> profilesList = json.decode(profilesJson);
    return profilesList.map((json) => UserProfile.fromJson(json)).toList();
  }

  // Save a profile
  Future<bool> saveProfile(UserProfile profile) async {
    try {
      final profiles = await getAllProfiles();

      // Check if profile exists and update, or add new
      final existingIndex = profiles.indexWhere((p) => p.id == profile.id);
      if (existingIndex != -1) {
        profiles[existingIndex] = profile.copyWith(updatedAt: DateTime.now());
      } else {
        profiles.add(profile);
      }

      // If this is the first profile, make it default
      if (profiles.length == 1) {
        profiles[0] = profiles[0].copyWith(isDefault: true);
        await setActiveProfile(profiles[0].id);
      }
      return await _saveAllProfiles(profiles);
    } catch (e) {
      log.log('Error saving profile: $e');
      return false;
    }
  }

  // Delete a profile
  Future<bool> deleteProfile(String profileId) async {
    try {
      final profiles = await getAllProfiles();
      final originalLength = profiles.length;
      profiles.removeWhere((profile) => profile.id == profileId);

      if (profiles.length == originalLength) {
        return false; // Profile not found
      }

      // If deleted profile was active, set first remaining as active
      final activeProfileId = await getActiveProfileId();
      if (activeProfileId == profileId && profiles.isNotEmpty) {
        await setActiveProfile(profiles.first.id);
        // Update first profile to be default
        profiles[0] = profiles[0].copyWith(isDefault: true);
      }
      return await _saveAllProfiles(profiles);
    } catch (e) {
      log.log('Error deleting profile: $e');
      return false;
    }
  }

  // Set active profile
  Future<bool> setActiveProfile(String profileId) async {
    try {
      await prefs.setString('active_profile_id', profileId);

      // Update all profiles to remove default status, then set new default
      final profiles = await getAllProfiles();
      for (int i = 0; i < profiles.length; i++) {
        profiles[i] = profiles[i].copyWith(
          isDefault: profiles[i].id == profileId,
        );
      }
      return await _saveAllProfiles(profiles);
    } catch (e) {
      log.log('Error setting active profile: $e');
      return false;
    }
  }

  // Create a new profile with unique ID
  UserProfile createNewProfile({
    required String name,
    required DateTime birthDate,
    String? birthTime,
    String? birthPlace,
    double? latitude,
    double? longitude,
  }) {
    final now = DateTime.now();
    final id =
        '${now.millisecondsSinceEpoch}_${name.replaceAll(' ', '_').toLowerCase()}';

    return UserProfile(
      id: id,
      name: name,
      birthDate: birthDate,
      birthTime: birthTime,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Import profile from birth info
  Future<UserProfile?> importFromBirthInfo({
    required String name,
    required DateTime birthDate,
    String? birthTime,
    String? birthPlace,
    double? latitude,
    double? longitude,
  }) async {
    final profile = createNewProfile(
      name: name,
      birthDate: birthDate,
      birthTime: birthTime,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
    );

    final success = await saveProfile(profile);
    return success ? profile : null;
  }

  // Clear all profiles (for testing/reset)
  Future<bool> clearAllProfiles() async {
    try {
      await prefs.remove('user_profiles');
      await prefs.remove('active_profile_id');
      return true;
    } catch (e) {
      log.log('Error clearing profiles: $e');
      return false;
    }
  }

  // Get profile count
  Future<int> getProfileCount() async {
    final profiles = await getAllProfiles();
    return profiles.length;
  }

  // Search profiles by name
  Future<List<UserProfile>> searchProfiles(String query) async {
    final profiles = await getAllProfiles();
    final lowerQuery = query.toLowerCase();

    return profiles.where((profile) {
      return profile.name.toLowerCase().contains(lowerQuery) ||
          (profile.birthPlace?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Pro subscription management
  Future<bool> upgradeUserToPro(String profileId) async {
    try {
      final profiles = await getAllProfiles();
      final profileIndex = profiles.indexWhere((p) => p.id == profileId);

      if (profileIndex == -1) return false;

      profiles[profileIndex] = profiles[profileIndex].copyWith(
        isPro: true,
        updatedAt: DateTime.now(),
      );
      return await _saveAllProfiles(profiles);
    } catch (e) {
      log.log('Error upgrading user to Pro: $e');
      return false;
    }
  }

  Future<bool> downgradeUserFromPro(String profileId) async {
    try {
      final profiles = await getAllProfiles();
      final profileIndex = profiles.indexWhere((p) => p.id == profileId);

      if (profileIndex == -1) return false;

      profiles[profileIndex] = profiles[profileIndex].copyWith(
        isPro: false,
        updatedAt: DateTime.now(),
      );

      return await _saveAllProfiles(profiles);
    } catch (e) {
      log.log('Error downgrading user from Pro: $e');
      return false;
    }
  }

  Future<bool> isUserPro(String profileId) async {
    try {
      final profiles = await getAllProfiles();
      final profile = profiles.firstWhere((p) => p.id == profileId);
      return profile.isPro;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isActiveUserPro() async {
    final activeProfile = await getActiveProfile();
    return activeProfile?.isPro ?? false;
  }

  // Private helper to save all profiles
  Future<bool> _saveAllProfiles(List<UserProfile> profiles) async {
    try {
      final profilesJson =
          json.encode(profiles.map((p) => p.toJson()).toList());
      return await prefs.setString('user_profiles', profilesJson);
    } catch (e) {
      log.log('Error saving all profiles: $e');
      return false;
    }
  }
}
