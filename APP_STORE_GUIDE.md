# App Store Deployment Checklist

## 📱 iOS App Store

### 1. Certificates & Provisioning
```bash
# Developer Account required ($99/year)
# Create App ID: com.astroyorumai.app
# Create Provisioning Profiles
# Setup code signing in Xcode
```

### 2. App Information
- **App Name**: AstroYorumAI - Astroloji Rehberi
- **Bundle ID**: com.astroyorumai.app
- **Version**: 1.0.0
- **Category**: Lifestyle / Reference
- **Age Rating**: 4+ (everyone)

### 3. Required Assets
```bash
# App Icons (all sizes in ios/Runner/Assets.xcassets/AppIcon.appiconset/)
# Launch Screen (ios/Runner/Assets.xcassets/LaunchImage.launchimage/)
# App Store Screenshots (6.7", 6.5", 5.5", 12.9")
```

### 4. Build & Upload
```bash
flutter build ios --release
# Open ios/Runner.xcworkspace in Xcode
# Archive → Upload to App Store Connect
```

## 🤖 Google Play Store

### 1. Developer Account Setup
```bash
# One-time $25 registration fee
# Create app in Play Console
# Package name: com.astroyorumai.app
```

### 2. App Details
- **App Name**: AstroYorumAI - Astroloji ve Burç Rehberi
- **Short Description**: Kişisel astroloji haritanızı oluşturun
- **Full Description**: [See detailed description below]
- **Category**: Lifestyle
- **Content Rating**: Everyone

### 3. Required Assets
```bash
# App Icon: 512x512 PNG
# Feature Graphic: 1024x500 PNG
# Screenshots: At least 2 phone screenshots
# Privacy Policy URL (required)
```

### 4. Build & Upload
```bash
flutter build appbundle --release
# Upload android/app/build/outputs/bundle/release/app-release.aab
```

## 📝 App Descriptions

### Turkish (Primary)
**Kısa Açıklama:**
Kişisel astroloji haritanızı oluşturun, günlük burç yorumlarını okuyun ve göksel olayları takip edin.

**Uzun Açıklama:**
AstroYorumAI, modern astroloji meraklıları için tasarlanmış kapsamlı bir astroloji uygulamasıdır.

**Özellikler:**
✨ Doğum haritası hesaplama ve analiz
🌟 Günlük, haftalık burç yorumları
📅 Göksel olaylar takvimi
🔮 Kişiselleştirilmiş astroloji tavsiyeleri
☁️ Bulut senkronizasyonu ile veri güvenliği
🌙 Ay döngüleri ve etkileri
🎯 Kolay kullanılabilir modern arayüz

### English (Secondary)
**Short Description:**
Create your personal astrology chart, read daily horoscopes, and track celestial events.

**Long Description:**
AstroYorumAI is a comprehensive astrology app designed for modern astrology enthusiasts.

**Features:**
✨ Birth chart calculation and analysis
🌟 Daily and weekly horoscope readings  
📅 Celestial events calendar
🔮 Personalized astrology insights
☁️ Cloud sync for data security
🌙 Moon phases and influences
🎯 Easy-to-use modern interface

## 🔒 Privacy Policy & Terms

### Privacy Policy Required Content
- Data collection (birth date, time, location)
- Cloud storage (Firebase)
- Analytics (if used)
- Third-party services
- User rights and data deletion

### Create Documents
```bash
# Create privacy policy at: https://astroyorumai.com/privacy
# Create terms of service at: https://astroyorumai.com/terms
```
