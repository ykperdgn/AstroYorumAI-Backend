# 🔧 GitHub Production Environment Variables Setup

## 🎯 Objective
GitHub'daki production environment'ına Railway deployment için gerekli environment variables ekleme rehberi.

## 📋 Mevcut Durum
- ✅ Railway backend active: `https://astroyorumai-backend-production.up.railway.app`
- ✅ Railway environment variables hazır: `railway_env_fix.json`
- ✅ Phase 2 tamamlandı: Flask + Flutter integration
- 🔄 **SIRA**: GitHub production environment variables

## 🚀 GitHub Repository Ayarları

### Adım 1: GitHub Repository Settings'e Git
```
1. https://github.com/ykperdgn/AstroYorumAI'e git
2. "Settings" tab'ına tıkla
3. Sol sidebar'da "Environments" seçeneğini bul
4. "production" environment'ını tıkla (varsa) veya "New environment" ile oluştur
```

### Adım 2: Environment Secrets Ekle
GitHub'da **Settings > Environments > production > Environment secrets** bölümünde şu değişkenleri ekle:

#### 🔐 Core Flask Configuration
```bash
Name: SECRET_KEY
Value: astroyorumai-production-secret-521949557-2025-railway

Name: FLASK_ENV
Value: production

Name: FLASK_DEBUG
Value: False

Name: FLASK_APP
Value: app.py
```

#### 🌐 Network & Server Configuration
```bash
Name: HOST
Value: 0.0.0.0

Name: PORT
Value: 8080

Name: PYTHONUNBUFFERED
Value: 1
```

#### 🎯 API Configuration
```bash
Name: API_VERSION
Value: 2.1.3-railway
```

#### 🔗 CORS Configuration
```bash
Name: CORS_ORIGINS
Value: https://astroyorumai.com,https://www.astroyorumai.com,https://astroyorumai-backend-production.up.railway.app,http://localhost:3000,http://localhost:8080
```

#### 🗄️ Database Configuration
```bash
Name: DATABASE_URL
Value: postgresql://postgres:password@postgres-production-e4dd.up.railway.app:5432/railway
```

#### ⚡ Performance & Keep-Alive
```bash
Name: ENABLE_KEEP_ALIVE
Value: true

Name: KEEP_ALIVE_URL
Value: https://astroyorumai-backend-production.up.railway.app/health
```

## 🧪 Doğrulama Testi

### Test 1: Environment Variables Kontrolü
GitHub Secrets ekledikten sonra, GitHub Actions veya manuel olarak test et:

```bash
# Railway backend'in çalıştığını doğrula
curl https://astroyorumai-backend-production.up.railway.app/health
```

Expected Response:
```json
{
  "status": "healthy",
  "version": "2.1.3-railway",
  "service": "AstroYorumAI API",
  "python_version": "3.11.x",
  "calculation_method": "flatlib Swiss Ephemeris",
  "platform": "Railway"
}
```

### Test 2: Full API Test
```bash
# Natal chart calculation test
curl -X POST https://astroyorumai-backend-production.up.railway.app/natal \
  -H "Content-Type: application/json" \
  -d '{
    "date": "1990-06-15",
    "time": "14:30",
    "latitude": 41.0082,
    "longitude": 28.9784
  }'
```

## ✅ Tamamlama Checklist

- [ ] GitHub repository'ye git
- [ ] Settings > Environments > production'a git
- [ ] 8 adet environment secret ekle:
  - [ ] SECRET_KEY
  - [ ] FLASK_ENV
  - [ ] FLASK_DEBUG
  - [ ] FLASK_APP
  - [ ] HOST
  - [ ] PYTHONUNBUFFERED
  - [ ] API_VERSION
  - [ ] CORS_ORIGINS
  - [ ] DATABASE_URL
  - [ ] ENABLE_KEEP_ALIVE
  - [ ] KEEP_ALIVE_URL
- [ ] Test et: Railway backend'in çalıştığını doğrula
- [ ] Test et: Natal chart calculation'ı doğrula

## 🎯 Phase 3 Hazırlık

### Sonraki Adımlar (Phase 3 için)
```bash
# Phase 3'te eklenecek ek değişkenler:

# Payment Integration
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# AI Integration  
OPENAI_API_KEY=sk-...

# Monitoring
SENTRY_DSN=https://...
```

---

**🚀 Status**: GitHub environment variables setup rehberi hazır  
**📅 Date**: December 28, 2024  
**🎯 Next**: GitHub'da manual olarak environment variables ekle  
**🔗 Railway Backend**: https://astroyorumai-backend-production.up.railway.app  

**⏱️ Estimated Time**: 5-10 dakika
