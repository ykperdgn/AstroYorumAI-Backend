#!/usr/bin/env python3
"""
Firebase Configuration Updater for AstroYorumAI
This script will help update Flutter configuration files after Firebase setup
"""

import json
import os

def update_android_config():
    """Instructions for Android configuration"""
    print("📱 ANDROID CONFIGURATION")
    print("-" * 40)
    print("1. Firebase Console'dan google-services.json dosyasını indirin")
    print("2. Dosyayı şu klasöre koyun:")
    print("   c:\\dev\\AstroYorumAI\\android\\app\\google-services.json")
    print()
    
    # Check if file exists
    android_config_path = "android/app/google-services.json"
    if os.path.exists(android_config_path):
        print("✅ google-services.json dosyası bulundu!")
    else:
        print("❌ google-services.json dosyası bulunamadı")
        print("   Lütfen Firebase Console'dan indirip belirtilen yere koyun")
    print()

def update_ios_config():
    """Instructions for iOS configuration"""
    print("🍎 iOS CONFIGURATION")
    print("-" * 40)
    print("1. Firebase Console'dan GoogleService-Info.plist dosyasını indirin")
    print("2. Dosyayı şu klasöre koyun:")
    print("   c:\\dev\\AstroYorumAI\\ios\\Runner\\GoogleService-Info.plist")
    print()
    
    # Check if file exists
    ios_config_path = "ios/Runner/GoogleService-Info.plist"
    if os.path.exists(ios_config_path):
        print("✅ GoogleService-Info.plist dosyası bulundu!")
    else:
        print("❌ GoogleService-Info.plist dosyası bulunamadı")
        print("   Lütfen Firebase Console'dan indirip belirtilen yere koyun")
    print()

def get_web_config():
    """Get web configuration from user"""
    print("🌐 WEB CONFIGURATION")
    print("-" * 40)
    print("Firebase Console'dan Web App config'ini kopyalayın ve aşağıya yapıştırın:")
    print()
    print("Örnek format:")
    print("""const firebaseConfig = {
  apiKey: "AIzaSyC...",
  authDomain: "astroyorumai-production.firebaseapp.com",
  projectId: "astroyorumai-production",
  storageBucket: "astroyorumai-production.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456"
};""")
    print()
    
    # For now, create template
    web_config_template = """
// Web configuration will be updated after Firebase setup
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY_HERE',
  appId: 'YOUR_WEB_APP_ID_HERE', 
  messagingSenderId: 'YOUR_SENDER_ID_HERE',
  projectId: 'astroyorumai-production',
  authDomain: 'astroyorumai-production.firebaseapp.com',
  storageBucket: 'astroyorumai-production.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID_HERE',
);"""
    
    return web_config_template

def create_flutter_config_template():
    """Create updated Flutter configuration template"""
    config_template = '''import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for production environment
class FirebaseConfigProduction {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY_HERE',
    appId: 'YOUR_ANDROID_APP_ID_HERE',
    messagingSenderId: 'YOUR_SENDER_ID_HERE',
    projectId: 'astroyorumai-production',
    authDomain: 'astroyorumai-production.firebaseapp.com',
    storageBucket: 'astroyorumai-production.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY_HERE',
    appId: 'YOUR_IOS_APP_ID_HERE',
    messagingSenderId: 'YOUR_SENDER_ID_HERE',
    projectId: 'astroyorumai-production',
    authDomain: 'astroyorumai-production.firebaseapp.com',
    storageBucket: 'astroyorumai-production.appspot.com',
    iosBundleId: 'com.astroyorumai.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY_HERE',
    appId: 'YOUR_WEB_APP_ID_HERE',
    messagingSenderId: 'YOUR_SENDER_ID_HERE',
    projectId: 'astroyorumai-production',
    authDomain: 'astroyorumai-production.firebaseapp.com',
    storageBucket: 'astroyorumai-production.appspot.com',
    measurementId: 'YOUR_MEASUREMENT_ID_HERE',
  );

  /// Get current platform configuration
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }
}

/// App Environment Configuration
class AppEnvironment {
  static const bool isProduction = true;
  static const String backendUrl = 'https://astroyorumai-api.onrender.com';
  static const bool enableDebugLogging = false;
  
  static String get firebaseProjectId => 'astroyorumai-production';
}'''

    return config_template

def main():
    print("🔥 Firebase Configuration Updater")
    print("=" * 50)
    print()
    
    # Check current working directory
    if not os.path.exists("pubspec.yaml"):
        print("❌ Error: This script must be run from the Flutter project root")
        print("Current directory:", os.getcwd())
        print("Expected directory: c:\\dev\\AstroYorumAI")
        return
    
    print("✅ Flutter project detected")
    print()
    
    # Android config
    update_android_config()
    
    # iOS config  
    update_ios_config()
    
    # Web config
    web_config = get_web_config()
    
    # Create updated configuration template
    config_template = create_flutter_config_template()
    
    print("📝 CONFIGURATION TEMPLATE CREATED")
    print("-" * 40)
    print("Template dosyası oluşturulacak:")
    print("lib/config/firebase_config_production_template.dart")
    print()
    
    # Write template file
    os.makedirs("lib/config", exist_ok=True)
    with open("lib/config/firebase_config_production_template.dart", "w", encoding="utf-8") as f:
        f.write(config_template)
    
    print("✅ Template dosyası oluşturuldu!")
    print()
    
    print("📋 NEXT STEPS:")
    print("-" * 40)
    print("1. Firebase Console'dan config dosyalarını indirin")
    print("2. Dosyaları belirtilen klasörlere koyun")
    print("3. Web config değerlerini template'e ekleyin")
    print("4. Template'i asıl config dosyasının yerine koyun")
    print("5. Flutter test çalıştırın: flutter test")
    print()
    print("🚀 Firebase setup tamamlandığında app beta testing'e hazır!")

if __name__ == "__main__":
    main()
