# 🔥 Firebase Manual Setup Guide - astroyorumai-production

## 📍 Mevcut Durum
✅ Firebase Projesi Oluşturulmuş: `astroyorumai-production`
🔗 URL: https://console.firebase.google.com/u/0/project/astroyorumai-production/

## 🚀 ADIM ADIM MANUEL SETUP

### 1️⃣ Firestore Database Setup
**Şu anda açık olan sayfa**: `/firestore`

1. **"Create database" butonuna tıklayın**
2. **Production mode** seçin (güvenlik kuralları ile)
3. **Location seçin**: `europe-west1 (Belgium)` - Türkiye'ye en yakın
4. **"Done" butonuna tıklayın**

### 2️⃣ Authentication Setup
Sol menüden **"Authentication"** seçin:

1. **"Get started" butonuna tıklayın**
2. **"Sign-in method" tab'ına gidin**
3. **Email/Password** aktifleştirin:
   - "Email/Password" satırına tıklayın
   - İlk toggle'ı aktifleştirin (Email/Password)
   - "Save" butonuna tıklayın
4. **Google Sign-In** aktifleştirin:
   - "Google" satırına tıklayın
   - Toggle'ı aktifleştirin
   - Project support email seçin
   - "Save" butonuna tıklayın

### 3️⃣ Flutter Platforms Ekleme

#### 📱 Android App Ekleme
1. Project Overview'da **"Add app"** → **Android** seçin
2. **Package name**: `com.astroyorumai.app`
3. **App nickname**: `AstroYorumAI Android`
4. **Debug signing certificate SHA-1**: (şimdilik boş bırakabilirsiniz)
5. **"Register app"** butonuna tıklayın
6. **google-services.json dosyasını indirin**
7. **"Next" → "Next" → "Continue to console"**

#### 🍎 iOS App Ekleme
1. **"Add app"** → **iOS** seçin
2. **Bundle ID**: `com.astroyorumai.app`
3. **App nickname**: `AstroYorumAI iOS`
4. **"Register app"** butonuna tıklayın
5. **GoogleService-Info.plist dosyasını indirin**
6. **"Next" → "Next" → "Continue to console"**

#### 🌐 Web App Ekleme
1. **"Add app"** → **Web** seçin
2. **App nickname**: `AstroYorumAI Web`
3. **Firebase Hosting**: ✅ Aktifleştirin
4. **"Register app"** butonuna tıklayın
5. **Config objesini kopyalayın** (sonra kullanacağız)
6. **"Continue to console"**

### 4️⃣ Firestore Security Rules
Firestore bölümüne gidin → **"Rules"** tab:

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
    
    // Public astro data (read-only for users)
    match /astro_data/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }
  }
}
```

**"Publish"** butonuna tıklayın.

## 📁 DOSYA YERLEŞTİRME

Setup tamamlandıktan sonra indirdiğiniz dosyaları yerleştirin:

### Android
```bash
# google-services.json dosyasını buraya koyun:
c:\dev\AstroYorumAI\android\app\google-services.json
```

### iOS  
```bash
# GoogleService-Info.plist dosyasını buraya koyun:
c:\dev\AstroYorumAI\ios\Runner\GoogleService-Info.plist
```

### Web Config
Web config'i `firebase_config_production.dart` dosyasına ekleyeceğiz.

## ✅ SETUP COMPLETION CHECKLIST

Manuel setup tamamlandığında bunları kontrol edin:

- [ ] Firestore Database oluşturuldu (europe-west1)
- [ ] Authentication aktifleştirildi (Email + Google)
- [ ] Android app eklendi (google-services.json indirildi)
- [ ] iOS app eklendi (GoogleService-Info.plist indirildi)
- [ ] Web app eklendi (config kopyalandı)
- [ ] Firestore security rules uygulandı

## 🔧 SONRAKI ADIM

Setup tamamlandığında bana şunları söyleyin:
1. ✅ "Firebase setup tamamlandı"
2. 📱 İndirilen dosyaları hangi klasörlere koyduğunuz
3. 🌐 Web config'i (ben Flutter dosyalarını güncelleyeceğim)

Bu işlem yaklaşık 10-15 dakika sürecektir. Herhangi bir adımda sorun yaşarsanız, hangi adımda kaldığınızı söyleyin!
