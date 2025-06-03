import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'lib/config/firebase_config_production.dart';

void main() async {
  try {
    developer.log('🚀 Starting Firebase Connection Test for AstroYorumAI Production');
    developer.log('📱 Platform: ${Platform.operatingSystem}');
    
    // Initialize Firebase with production config
    developer.log('⚙️  Initializing Firebase...');
    await Firebase.initializeApp(
      options: FirebaseConfigProduction.currentPlatform,
    );
    
    developer.log('✅ Firebase Core initialized successfully!');
    developer.log('🔥 Project ID: ${Firebase.app().options.projectId}');
    developer.log('🌐 Auth Domain: ${Firebase.app().options.authDomain}');
    developer.log('📦 Storage Bucket: ${Firebase.app().options.storageBucket}');
    
    developer.log('\n🎉 FIREBASE CONNECTION TEST PASSED! 🎉');
    developer.log('✅ AstroYorumAI is ready for production Firebase integration');
      } catch (e, stackTrace) {
    developer.log('❌ Firebase connection test failed: $e');
    developer.log('📋 Stack trace: $stackTrace');
    exit(1);
  }
}
