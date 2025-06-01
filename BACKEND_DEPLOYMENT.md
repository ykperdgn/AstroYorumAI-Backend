# AstroYorumAI Backend Deployment Guide

## Heroku Deployment (Ücretsiz/Hızlı)

### 1. Install Heroku CLI
```bash
# Windows
choco install heroku-cli
# macOS
brew install heroku/brew/heroku
```

### 2. Deploy to Heroku
```bash
cd c:\dev\AstroYorumAI
heroku login
heroku create astroyorumai-api
git add .
git commit -m "Initial backend deployment"
heroku git:remote -a astroyorumai-api
git push heroku main
```

### 3. Set Environment Variables
```bash
heroku config:set FLASK_ENV=production
heroku config:set PORT=8080
```

### 4. Verify Deployment
```bash
heroku open
# Test: https://astroyorumai-api.herokuapp.com/health
```

## Railway Deployment (Alternatif)

### 1. Install Railway CLI
```bash
npm install -g @railway/cli
```

### 2. Deploy
```bash
railway login
railway new
railway link
railway up
```

## Production Configuration Updates

### 1. Update CORS Origins
Update `astro_api.py` with your actual domain:
```python
CORS(app, origins=['https://astroyorumai.com', 'https://www.astroyorumai.com'])
```

### 2. Update Flutter HTTP Endpoints
Update `lib/services/natal_chart_service.dart`:
```dart
final apiUrl = 'https://astroyorumai-api.herokuapp.com/natal';
```
