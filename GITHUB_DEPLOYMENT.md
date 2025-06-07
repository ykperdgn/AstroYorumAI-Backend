# GitHub Repository Setup ve Cloud Deployment

## Adım 1: GitHub Repository Oluştur

1. GitHub.com'a git ve yeni repository oluştur:
   - Repository name: `AstroYorumAI-Backend`
   - Description: `Flutter AstroYorumAI app backend API - Natal chart calculations with Flask`
   - Public (Render.com free tier için gerekli)
   - README.md ekleme (zaten var)

2. Repository oluşturduktan sonra aşağıdaki komutları çalıştır:

```bash
git remote add origin https://github.com/KULLANICI_ADINIZ/AstroYorumAI-Backend.git
git branch -M main
git push -u origin main
```

## Adım 2: Render.com Deployment

1. Render.com'a git ve GitHub ile giriş yap
2. "New +" > "Web Service" seç
3. GitHub repository'ni bağla: `AstroYorumAI-Backend`
4. Deployment ayarları:
   - **Name**: `astroyorumai-api`
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn astro_api:app`
   - **Instance Type**: `Free`
   - **Advanced Settings**:
     - Auto-Deploy: Yes
     - Environment Variables:
       - `FLASK_ENV` = `production`
       - `PYTHONPATH` = `/opt/render/project/src`

5. "Create Web Service" tıkla

## Adım 3: Deployment Sonrası Test

Deployment tamamlandıktan sonra aşağıdaki URL'leri test et:

```
https://astroyorumai-api.onrender.com/health
https://astroyorumai-api.onrender.com/natal
```

## Adım 4: Flutter App Güncelleme

Deployment URL'ini Flutter app'de güncelle:
- `lib/services/` klasöründeki API endpoint'lerini yeni URL ile değiştir

## Backup Deployment Options

Eğer Render.com'da sorun yaşarsan:

### Heroku Alternative:
```bash
heroku create astroyorumai-api
git push heroku main
```

### Alternative Deployment Options:
1. Render.com (currently used) ✅
2. Heroku (paid plans only)
3. DigitalOcean App Platform

## Troubleshooting

### Common Issues:
1. **Build fails**: `requirements.txt` kontrol et
2. **App crashes**: Logs'u kontrol et: Render Dashboard > Service > Logs
3. **CORS errors**: Frontend URL'ini kontrol et

### Debug Commands:
```bash
# Local test
python astro_api.py

# Requirements check
pip install -r requirements.txt

# Gunicorn test
gunicorn astro_api:app
```

## Monitoring

Render.com'da service health'i monitor et:
- Dashboard > Service > Metrics
- Logs tab'ında error'ları kontrol et
- Health endpoint'i düzenli test et
