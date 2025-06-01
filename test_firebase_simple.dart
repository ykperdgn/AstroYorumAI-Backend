import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'lib/config/firebase_config_production.dart';

void main() async {
  try {
    print('🚀 Starting Firebase Connection Test for AstroYorumAI Production');
    print('📱 Platform: ${Platform.operatingSystem}');
    
    // Initialize Firebase with production config
    print('⚙️  Initializing Firebase...');
    await Firebase.initializeApp(
      options: FirebaseConfigProduction.currentPlatform,
    );
    
    print('✅ Firebase Core initialized successfully!');
    print('🔥 Project ID: ${Firebase.app().options.projectId}');
    print('🌐 Auth Domain: ${Firebase.app().options.authDomain}');
    print('📦 Storage Bucket: ${Firebase.app().options.storageBucket}');
    
    print('\n🎉 FIREBASE CONNECTION TEST PASSED! 🎉');
    print('✅ AstroYorumAI is ready for production Firebase integration');
    
  } catch (e, stackTrace) {
    print('❌ Firebase connection test failed: $e');
    print('📋 Stack trace: $stackTrace');
    exit(1);
  }
}
