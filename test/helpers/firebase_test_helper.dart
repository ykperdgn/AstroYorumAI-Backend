// Firebase Test Helper
// Bu dosya test ortamında Firebase uyarılarını azaltmak için kullanılır

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test ortamında Firebase initialization uyarılarını önlemek için
/// platform kanallarını mock eder
void setupFirebaseTestMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Firebase Core platform kanalını mock et
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firebase#initializeCore':
          return <String, dynamic>{
            'name': '[DEFAULT]',
            'options': <String, dynamic>{
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project-id',
            },
            'pluginConstants': <String, dynamic>{},
          };
        case 'Firebase#initializeApp':
          return <String, dynamic>{
            'name': '[DEFAULT]',
            'options': <String, dynamic>{
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project-id',
            },
            'pluginConstants': <String, dynamic>{},
          };
        default:
          return <String, dynamic>{};
      }
    },
  );

  // Firebase Auth platform kanalını mock et
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_auth'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Auth#registerChangeListener':
        case 'Auth#registerAuthStateListener':
        case 'Auth#registerIdTokenListener':
          return <String, dynamic>{'user': null};
        case 'Auth#signInWithEmailAndPassword':
          return <String, dynamic>{
            'user': <String, dynamic>{
              'uid': 'test-uid',
              'email': 'test@example.com',
            }
          };
        case 'Auth#signOut':
          return null;
        default:
          return <String, dynamic>{};
      }
    },
  );

  // Cloud Firestore platform kanalını mock et
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/cloud_firestore'),
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
    },
  );
  // Firebase Messaging platform kanalını mock et
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_messaging'),
    (MethodCall methodCall) async {
      return <String, dynamic>{};
    },
  );
}

/// Test sonunda mock'ları temizle
void tearDownFirebaseTestMocks() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    null,
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_auth'),
    null,
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/cloud_firestore'),
    null,
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_messaging'),
    null,
  );
}
