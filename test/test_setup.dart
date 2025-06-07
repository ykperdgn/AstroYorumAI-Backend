// Test setup file for Firebase initialization and mocking
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroyorumai/services/auth_service.dart';
import 'package:astroyorumai/services/cloud_sync_service.dart';

// Global map to store test SharedPreferences values
Map<String, dynamic> _testSharedPreferences = {};

/// Reset shared preferences for testing
void resetTestSharedPreferences() {
  _testSharedPreferences.clear();
}

/// Set a test value in SharedPreferences
void setTestSharedPreferencesValue(String key, dynamic value) {
  _testSharedPreferences[key] = value;
}

class MockFirebaseApp implements FirebaseApp {
  @override
  String get name => '[DEFAULT]';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      );
  @override
  bool get isAutomaticDataCollectionEnabled => false;

  set isAutomaticDataCollectionEnabled(bool enabled) {}

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}

/// Setup Firebase for testing environment
Future<void> setupFirebaseForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Mock all Firebase-related platform channels
  const firebaseCoreChannel = MethodChannel('plugins.flutter.io/firebase_core');
  const firebaseAuthChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  const firestoreChannel = MethodChannel('plugins.flutter.io/cloud_firestore');
  const sharedPreferencesChannel =
      MethodChannel('plugins.flutter.io/shared_preferences');

  // Mock Firebase Core
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(firebaseCoreChannel,
          (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Firebase#initializeCore':
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project-id',
            },
            'pluginConstants': <String, dynamic>{},
          }
        ];
      case 'Firebase#initializeApp':
        return {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'test-api-key',
            'appId': 'test-app-id',
            'messagingSenderId': 'test-sender-id',
            'projectId': 'test-project-id',
          },
          'pluginConstants': <String, dynamic>{},
        };
      default:
        return null;
    }
  });

  // Mock Firebase Auth
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(firebaseAuthChannel,
          (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Auth#registerIdTokenListener':
      case 'Auth#registerAuthStateListener':
        return <String, dynamic>{};
      case 'Auth#signInWithEmailAndPassword':
        return {
          'user': {
            'uid': 'test-uid',
            'email': 'test@example.com',
          }
        };
      case 'Auth#createUserWithEmailAndPassword':
        return {
          'user': {
            'uid': 'test-uid',
            'email': 'test@example.com',
          }
        };
      case 'Auth#signOut':
        return null;
      default:
        return null;
    }
  });
  // Mock Firestore
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(firestoreChannel,
          (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Firestore#enableNetwork':
      case 'Firestore#disableNetwork':
        return null;
      case 'Query#snapshots':
        return 'test-stream-id';
      case 'DocumentReference#snapshots':
        return 'test-doc-stream-id';
      case 'DocumentReference#set':
      case 'DocumentReference#update':
      case 'DocumentReference#delete':
        return null;
      default:
        return <String, dynamic>{};
    }
  });

  // Mock SharedPreferences with dynamic response based on test data
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(sharedPreferencesChannel,
          (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getAll':
        return Map<String, dynamic>.from(_testSharedPreferences);
      case 'getString':
        final String key = methodCall.arguments['key'];
        return _testSharedPreferences[key] as String?;
      case 'setString':
        final String key = methodCall.arguments['key'];
        final String value = methodCall.arguments['value'];
        _testSharedPreferences[key] = value;
        return true;
      case 'remove':
        final String key = methodCall.arguments['key'];
        _testSharedPreferences.remove(key);
        return true;
      case 'clear':
        _testSharedPreferences.clear();
        return true;
      default:
        return null;
    }
  });

  // DO NOT initialize Firebase in tests - use mocks only
  // Firebase.initializeApp() causes platform channel errors in test environment
}

/// Reset all service singletons for testing
void resetServiceSingletons() {
  // Reset SharedPreferences test data
  resetTestSharedPreferences();

  // Reset AuthService singleton
  AuthService.testInstance = null;

  // Reset CloudSyncService singleton
  CloudSyncService.testInstance = null;
}
