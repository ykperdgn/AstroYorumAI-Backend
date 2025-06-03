import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_birth_info.dart';
import 'dart:developer' as log;

class UserPreferencesService {
  static const String _keyUserBirthInfo = 'userBirthInfo';

  Future<void> saveUserBirthInfo(UserBirthInfo birthInfo) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert UserBirthInfo to a Map<String, dynamic>
    // DateTime needs to be stored as ISO8601 string
    // TimeOfDay is already a string in our model
    Map<String, dynamic> birthInfoMap = {
      'name': birthInfo.name,
      'birthDate': birthInfo.birthDate?.toIso8601String(),
      'birthTime': birthInfo.birthTime,
      'birthPlace': birthInfo.birthPlace,
      'latitude': birthInfo.latitude,
      'longitude': birthInfo.longitude,
    };    String jsonString = json.encode(birthInfoMap);
    await prefs.setString(_keyUserBirthInfo, jsonString);
    log.log('UserBirthInfo saved: $jsonString');
  }

  Future<UserBirthInfo?> loadUserBirthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_keyUserBirthInfo);

    if (jsonString != null) {
      try {
        Map<String, dynamic> birthInfoMap = json.decode(jsonString);
        // Convert ISO8601 string back to DateTime
        DateTime? birthDate = birthInfoMap['birthDate'] != null
            ? DateTime.tryParse(birthInfoMap['birthDate'])
            : null;

        // Validate that essential fields are present and correctly typed
        if (birthDate != null &&
            birthInfoMap['birthTime'] is String &&
            birthInfoMap['latitude'] is double &&            birthInfoMap['longitude'] is double) {
              
          log.log('UserBirthInfo loaded: $birthInfoMap');
          return UserBirthInfo(
            name: birthInfoMap['name'] as String?, // Allow null name if not saved
            birthDate: birthDate,
            birthTime: birthInfoMap['birthTime'] as String,
            birthPlace: birthInfoMap['birthPlace'] as String?,
            latitude: birthInfoMap['latitude'] as double,
            longitude: birthInfoMap['longitude'] as double,
          );        } else {
          log.log('UserBirthInfo loaded but failed validation. Data: $birthInfoMap');
          // Clear invalid data to prevent repeated load failures
          await clearUserBirthInfo();
          return null;
        }
      } catch (e) {
        log.log('Error decoding UserBirthInfo: $e. Clearing invalid data.');
        await clearUserBirthInfo(); // Clear corrupted data
        return null;
      }
    }
    log.log('No UserBirthInfo found in SharedPreferences.');
    return null;
  }
  Future<void> clearUserBirthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserBirthInfo);
    log.log('UserBirthInfo cleared from SharedPreferences.');
  }
}
