# Firebase Production Project Setup

## 🎯 Project Details
- **Project Name**: `astroyorumai-production`
- **Project ID**: `astroyorumai-prod` (will be auto-generated)
- **Region**: `europe-west1` (Frankfurt) - closest to Turkish users
- **Bundle ID**: `com.astroyorumai.app`

## 📱 Platform Configuration

### Android App
```
App nickname: AstroYorumAI Android
Package name: com.astroyorumai.app
SHA-1 certificate fingerprint: [PRODUCTION_SHA1_HERE]
```

### iOS App
```
App nickname: AstroYorumAI iOS
Bundle ID: com.astroyorumai.app
App Store ID: [TO_BE_GENERATED]
```

### Web App
```
App nickname: AstroYorumAI Web
Public-facing name: AstroYorumAI
Hosting URL: astroyorumai.web.app
```

## 🔐 Authentication Configuration

### Email/Password
- ✅ Enable Email/Password authentication
- ✅ Enable Email link (passwordless) sign-in
- ✅ Enable email enumeration protection

### Google Sign-In
- ✅ Enable Google Sign-In
- ✅ Configure OAuth consent screen
- ✅ Add production domains

### Apple Sign-In (iOS)
- ✅ Enable Apple Sign-In
- ✅ Configure Apple Developer account
- ✅ Add Apple services ID

## 🗄️ Firestore Database

### Database Configuration
```
Database ID: (default)
Location: europe-west1 (Frankfurt)
Mode: Production mode
```

### Collections Structure
```
/users/{userId}
  - uid: string
  - email: string
  - displayName: string
  - photoURL: string
  - createdAt: timestamp
  - lastLoginAt: timestamp
  - subscriptionStatus: string
  - preferences: object

/users/{userId}/natal_charts/{chartId}
  - name: string
  - birthDate: string
  - birthTime: string
  - birthPlace: object
  - chartData: object
  - createdAt: timestamp
  - isPrivate: boolean

/astrology_data/{dataType}
  - signs: array
  - planets: array
  - houses: array
  - aspects: array
```

### Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Natal charts subcollection
      match /natal_charts/{chartId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Public astrology data (read-only for authenticated users)
    match /astrology_data/{document} {
      allow read: if request.auth != null;
    }
    
    // Admin only collections
    match /admin/{document} {
      allow read, write: if request.auth != null && 
        request.auth.token.email in ['admin@astroyorumai.com'];
    }
  }
}
```

## ☁️ Cloud Functions (Future)

### Planned Functions
1. **onUserCreate**: Initialize user profile and preferences
2. **generateDailyHoroscope**: Daily horoscope generation
3. **validateSubscription**: Premium subscription validation
4. **sendNotifications**: Push notification service
5. **backupUserData**: Automated user data backup

## 📊 Analytics Configuration

### Google Analytics 4
- ✅ Enable Google Analytics
- ✅ Enhanced measurement
- ✅ Custom events for:
  - Natal chart generation
  - Premium feature usage
  - User engagement metrics

## 🔧 Production Environment Variables

### Flutter App Configuration
```dart
// lib/config/firebase_config_prod.dart
class FirebaseConfigProd {
  static const String projectId = 'astroyorumai-prod';
  static const String apiKey = '[PRODUCTION_API_KEY]';
  static const String authDomain = 'astroyorumai-prod.firebaseapp.com';
  static const String storageBucket = 'astroyorumai-prod.appspot.com';
  static const String messagingSenderId = '[SENDER_ID]';
  static const String appId = '[APP_ID]';
  static const String measurementId = '[MEASUREMENT_ID]';
}
```

## 🚀 Deployment Steps

### Phase 1: Project Setup
1. Create Firebase project in console
2. Add Android/iOS/Web apps
3. Download configuration files
4. Update Flutter app with production config

### Phase 2: Authentication Setup
1. Configure authentication providers
2. Set up OAuth consent screen
3. Test authentication flow

### Phase 3: Database Setup
1. Create Firestore database
2. Deploy security rules
3. Initialize astrology data collections

### Phase 4: Testing & Validation
1. Test all authentication methods
2. Validate database operations
3. Test production API integration

### Phase 5: Go Live
1. Deploy to app stores
2. Enable production monitoring
3. Launch beta testing program

## 📋 Beta Testing Configuration

### TestFlight (iOS)
- Group: AstroYorumAI Beta Testers
- Max testers: 30
- Testing period: 4 weeks

### Google Play Console (Android)
- Track: Internal testing
- Max testers: 30
- Testing period: 4 weeks

### Web Beta
- Custom domain: beta.astroyorumai.com
- Access: Invite only
- Max testers: 20

---
*Created: June 1, 2025*
*Status: Ready for implementation*
