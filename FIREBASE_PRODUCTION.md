# Firebase Production Setup Guide

## 1. Create Production Firebase Project

### Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "astroyorumai-prod"
3. Enable Analytics (optional)
4. Choose your billing plan

### Enable Required Services
```bash
# Authentication
- Email/Password provider
- Anonymous authentication (optional)

# Firestore Database
- Start in production mode
- Choose your region (europe-west1 for Turkey)

# Storage (for future use)
- Default rules
```

## 2. Download Configuration Files

### For Android
1. Add Android app in Firebase console
2. Package name: `com.astroyorumai.app` (update from com.example.astroyorumai)
3. Download `google-services.json`
4. Replace `android/app/google-services.json`

### For iOS
1. Add iOS app in Firebase console
2. Bundle ID: `com.astroyorumai.app`
3. Download `GoogleService-Info.plist`
4. Replace `ios/Runner/GoogleService-Info.plist`

### For Web
1. Add Web app in Firebase console
2. App nickname: "AstroYorumAI Web"
3. Copy configuration and update `lib/main.dart`

## 3. Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public read access for astrology data (if needed)
    match /astrology_data/{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

### Storage Rules (for future)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 4. Environment Configuration

Create production environment file:
```bash
# Create .env.production
FIREBASE_PROJECT_ID=astroyorumai-prod
FIREBASE_API_KEY=your-production-api-key
FIREBASE_APP_ID=your-production-app-id
```
