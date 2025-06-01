# 🔥 Firebase Production Project Setup Instructions

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. **Project name**: `AstroYorumAI Production`
4. **Project ID**: `astroyorumai-production` (or auto-generated)
5. Enable Google Analytics (recommended for production)
6. Choose Analytics location: **Europe** (for Turkish users)

## Step 2: Add Applications

### Android App
1. Click "Add app" → Android
2. **Package name**: `com.astroyorumai.app`
3. **App nickname**: `AstroYorumAI Android`
4. **Debug signing certificate SHA-1**: [Generate from keystore]
5. Download `google-services.json`
6. Place in `android/app/` folder

### iOS App  
1. Click "Add app" → iOS
2. **Bundle ID**: `com.astroyorumai.app`
3. **App nickname**: `AstroYorumAI iOS`
4. Download `GoogleService-Info.plist`
5. Add to iOS project in Xcode

### Web App
1. Click "Add app" → Web
2. **App nickname**: `AstroYorumAI Web`
3. **Hosting**: Enable Firebase Hosting
4. Copy the config object

## Step 3: Enable Authentication

1. Go to **Authentication** → **Sign-in method**
2. Enable:
   - ✅ **Email/Password**
   - ✅ **Google** (configure OAuth)
   - ✅ **Apple** (for iOS)

## Step 4: Setup Firestore Database

1. Go to **Firestore Database**
2. **Create database** → **Start in production mode**
3. **Location**: `europe-west1` (Frankfurt)
4. Apply security rules (see below)

## Step 5: Configure Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Natal charts are private to users
    match /natal_charts/{chartId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Public astrological data (read-only)
    match /astro_data/{document=**} {
      allow read: if true;
      allow write: if false; // Admin only via backend
    }
  }
}
```

## Step 6: Update Flutter Configuration

After creating the Firebase project, update these files:

### `lib/config/firebase_config_production.dart`
Replace placeholder values with real Firebase config:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_REAL_ANDROID_API_KEY',
  appId: 'YOUR_REAL_ANDROID_APP_ID', 
  messagingSenderId: 'YOUR_REAL_SENDER_ID',
  projectId: 'astroyorumai-production',
  authDomain: 'astroyorumai-production.firebaseapp.com',
  storageBucket: 'astroyorumai-production.appspot.com',
);
```

### Android Configuration
1. Replace `android/app/google-services.json`
2. Verify `android/app/build.gradle` has correct package name

### iOS Configuration  
1. Replace `ios/Runner/GoogleService-Info.plist`
2. Update bundle ID in Xcode project

## Step 7: Test Configuration

Run these commands to verify setup:

```bash
# Test Android
flutter run --release -d android

# Test iOS  
flutter run --release -d ios

# Test Web
flutter run -d chrome --web-renderer html
```

## Next Steps After Setup

1. ✅ **Backend Integration**: Ensure API endpoints work
2. ✅ **Authentication Flow**: Test login/register 
3. ✅ **Data Persistence**: Verify Firestore operations
4. ✅ **Beta Testing**: Deploy to TestFlight/Play Console
5. ✅ **Performance**: Monitor analytics and crash reports

## Production Checklist

- [ ] Firebase project created with production settings
- [ ] All platforms (Android/iOS/Web) configured
- [ ] Authentication providers enabled
- [ ] Firestore security rules applied
- [ ] Flutter app successfully connects to production Firebase
- [ ] Backend API integrated with production database
- [ ] Analytics and crash reporting enabled
- [ ] Privacy policy and terms of service added
- [ ] App store assets prepared (icons, screenshots, descriptions)

## Security Notes

⚠️ **IMPORTANT**: Keep these secure and never commit to Git:
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)  
- Firebase API keys should be in environment variables for web

Add to `.gitignore`:
```
# Firebase config files
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

## Support Resources

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Auth Guide](https://firebase.google.com/docs/auth)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
