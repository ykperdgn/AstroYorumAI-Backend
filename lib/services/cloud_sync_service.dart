import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/celestial_event.dart';
import 'auth_service.dart';
import 'profile_management_service.dart';
import 'astrology_calendar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CloudSyncService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  static const String _lastSyncKey = 'last_cloud_sync';
  CloudSyncService({FirebaseFirestore? firestore, AuthService? authService})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _authService = authService ?? AuthService.instance;
      
  // Static instance for convenience
  static CloudSyncService? _instance;
  static CloudSyncService get instance => _instance ??= CloudSyncService();

  // For testing - allows dependency injection
  static set testInstance(CloudSyncService? testInstance) {
    _instance = testInstance;
  }

  // Sync all user data to cloud
  Future<void> syncToCloud() async {
    if (!_authService.isSignedIn) {
      throw Exception('Bulut senkronizasyonu için giriş yapmalısınız');
    }

    try {
      final userId = _authService.currentUser!.uid;
        // Get local data
      final profileService = await ProfileManagementService.getInstance();
      final profiles = await profileService.getAllProfiles();
      final activeProfileId = await profileService.getActiveProfileId();
      final calendarEvents = await AstrologyCalendarService.getAllEvents();

      // Prepare data for upload
      final userData = {
        'profiles': profiles.map((p) => p.toJson()).toList(),
        'activeProfileId': activeProfileId,
        'calendarEvents': calendarEvents.map((e) => e.toJson()).toList(),
        'lastSyncTimestamp': FieldValue.serverTimestamp(),
        'appVersion': '1.0.0',
      };

      // Upload to Firestore
      await _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));

      // Update local sync timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      print('Cloud sync completed successfully');
    } catch (e) {
      throw Exception('Bulut senkronizasyonu başarısız: $e');
    }
  }
  // Sync data from cloud to local
  Future<void> syncFromCloud() async {
    if (!_authService.isSignedIn) {
      throw Exception('Bulut senkronizasyonu için giriş yapmalısınız');
    }

    try {
      final userId = _authService.currentUser!.uid;
      
      // Get data from Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        print('No cloud data found for user');
        return;
      }

      final data = doc.data()!;
      
      // Restore profiles
      if (data['profiles'] != null) {
        final List<dynamic> profilesData = data['profiles'];
        final profiles = profilesData.map((p) => UserProfile.fromJson(p)).toList();
          // Clear existing profiles and restore from cloud
        final profileService = await ProfileManagementService.getInstance();
        await profileService.clearAllProfiles();
        for (final profile in profiles) {
          await profileService.saveProfile(profile);
        }

        // Restore active profile
        if (data['activeProfileId'] != null) {
          await profileService.setActiveProfile(data['activeProfileId']);
        }
      }

      // Restore calendar events
      if (data['calendarEvents'] != null) {
        final List<dynamic> eventsData = data['calendarEvents'];
        final events = eventsData.map((e) => CelestialEvent.fromJson(e)).toList();
        
        // Save calendar events
        final prefs = await SharedPreferences.getInstance();
        final eventsJson = json.encode(events.map((e) => e.toJson()).toList());
        await prefs.setString('celestial_events', eventsJson);
      }

      // Update local sync timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      print('Cloud restore completed successfully');
    } catch (e) {
      throw Exception('Bulut verisi geri yüklenemedi: $e');
    }
  }
  // Check if sync is needed
  Future<bool> needsSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    
    if (lastSyncStr == null) return true;
    
    final lastSync = DateTime.parse(lastSyncStr);
    final daysSinceSync = DateTime.now().difference(lastSync).inDays;
    
    return daysSinceSync >= 1; // Sync daily
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    
    if (lastSyncStr == null) return null;
    return DateTime.parse(lastSyncStr);
  }

  // Auto sync on app start
  Future<void> autoSync() async {
    if (!_authService.isSignedIn) return;
    
    try {
      if (await needsSync()) {
        await syncToCloud();
      }
    } catch (e) {
      print('Auto sync failed: $e');
      // Don't throw error for auto sync to avoid blocking app startup
    }
  }

  // Backup single profile
  Future<void> backupProfile(UserProfile profile) async {
    if (!_authService.isSignedIn) {
      throw Exception('Profil yedeklemesi için giriş yapmalısınız');
    }

    try {
      final userId = _authService.currentUser!.uid;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profile.id)
          .set(profile.toJson());
      
      print('Profile backed up: ${profile.name}');
    } catch (e) {
      throw Exception('Profil yedeklenemedi: $e');
    }
  }
  // Restore single profile
  Future<UserProfile?> restoreProfile(String profileId) async {
    if (!_authService.isSignedIn) {
      throw Exception('Profil geri yüklemesi için giriş yapmalısınız');
    }

    try {
      final userId = _authService.currentUser!.uid;
      
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc(profileId)
          .get();
      
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Profil geri yüklenemedi: $e');
    }
  }

  // Get all cloud profiles
  Future<List<UserProfile>> getCloudProfiles() async {
    if (!_authService.isSignedIn) {
      throw Exception('Bulut profilleri görüntülemek için giriş yapmalısınız');
    }

    try {
      final userId = _authService.currentUser!.uid;
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .get();
      
      return querySnapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Bulut profilleri alınamadı: $e');
    }
  }

  // Delete all cloud data
  Future<void> deleteCloudData() async {
    if (!_authService.isSignedIn) {
      throw Exception('Bulut verisi silmek için giriş yapmalısınız');
    }

    try {
      final userId = _authService.currentUser!.uid;
      
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
      
      // Delete profiles subcollection
      final profilesQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .get();
      
      for (final doc in profilesQuery.docs) {
        await doc.reference.delete();
      }
      
      print('All cloud data deleted');
    } catch (e) {
      throw Exception('Bulut verisi silinemedi: $e');
    }
  }

  // Instance methods expected by tests
  Future<void> syncUserDataToCloud(User user) async {
    if (user.uid.isEmpty) {
      throw Exception('Invalid user for cloud sync');
    }
    await syncToCloud();
  }

  Future<void> restoreUserDataFromCloud(User user) async {
    if (user.uid.isEmpty) {
      throw Exception('Invalid user for cloud restore');
    }
    await syncFromCloud();
  }

  Future<DateTime?> getLastSyncTimestamp(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString(_lastSyncKey);
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }

  // Delete user data from cloud (for test compatibility)
  Future<void> deleteUserDataFromCloud(User user) async {
    if (user.uid.isEmpty) {
      throw Exception('Invalid user for cloud deletion');
    }
    await deleteAllCloudData(user.uid);
  }

  // Helper method to delete all cloud data for a user
  Future<void> deleteAllCloudData(String userId) async {
    try {
      // Delete user profiles
      final profilesQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .get();
      
      for (var doc in profilesQuery.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
      
      print('All cloud data deleted for user: $userId');
    } catch (e) {
      print('Error deleting cloud data: $e');
      throw Exception('Failed to delete cloud data: $e');
    }
  }
}
