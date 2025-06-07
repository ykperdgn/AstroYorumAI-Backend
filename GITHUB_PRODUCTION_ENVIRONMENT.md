# 🚀 GitHub Production Environment Configuration
# AstroYorumAI - Render.com Production Deployment

## 🎯 GitHub Environment: "production"

### Environment Variables (GitHub Secrets)

```bash
# Core Flask Configuration
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=your-production-secret-key-here

# Server Configuration
PORT=8080
HOST=0.0.0.0
WEB_CONCURRENCY=1
PYTHONUNBUFFERED=1

# API Configuration
API_VERSION=2.1.3
LOG_LEVEL=INFO

# CORS Configuration (Production)
CORS_ORIGINS=https://astroyorumai.com,https://www.astroyorumai.com,https://astroyorumai-api.onrender.com

# Free Tier Optimizations
ENABLE_KEEP_ALIVE=true
KEEP_ALIVE_URL=https://astroyorumai-api.onrender.com/health

# Database (Choose one option)
# Option 1: Supabase (Recommended)
DATABASE_URL=postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

# Option 2: PlanetScale
# DATABASE_URL=mysql://[username]:[password]@[host]/[database]?sslmode=require

# Option 3: ElephantSQL
# DATABASE_URL=postgres://[user]:[password]@[host]/[database]

# Payment Gateway (When ready)
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# AI Integration (When ready)
OPENAI_API_KEY=sk-...

# Monitoring (Optional)
SENTRY_DSN=https://...
```

## 🔧 Render.com Deployment Configuration

### Build Settings
```yaml
# From render.yaml
buildCommand: pip install --upgrade pip && pip install -r requirements.txt
startCommand: gunicorn --bind 0.0.0.0:$PORT app:app --timeout 120 --workers 1
```

### Service Settings
- **Name**: astroyorumai-backend
- **Region**: Oregon
- **Plan**: Free
- **Runtime**: Python 3
- **Branch**: main
- **Auto-Deploy**: Yes

## 🌐 Production URLs

### Live API
- **Base URL**: `https://astroyorumai-api.onrender.com`
- **Health Check**: `https://astroyorumai-api.onrender.com/health`
- **Status**: `https://astroyorumai-api.onrender.com/status`

### API Endpoints
```
GET  /health          - Health check
GET  /status          - Service status
GET  /test            - API test
POST /natal           - Natal chart calculation
POST /synastry        - Relationship compatibility
POST /transit         - Transit analysis
POST /horary          - Horary astrology
POST /solar-return    - Solar return chart
POST /progression     - Progression chart
POST /composite       - Composite chart
```

## 🔐 GitHub Actions Workflow (Optional)

If you want to set up automated deployment:

```yaml
# .github/workflows/deploy-production.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Deploy to Render
      run: |
        echo "Render auto-deploys from GitHub"
        echo "Production URL: https://astroyorumai-api.onrender.com"
        
    - name: Health Check
      run: |
        sleep 30
        curl -f https://astroyorumai-api.onrender.com/health
```

## 📊 Environment Setup Steps

### 1. GitHub Environment Configuration
1. Go to repository **Settings** → **Environments**
2. Click **"production"** environment
3. Add environment secrets above
4. Set protection rules if needed

### 2. Render.com Configuration
1. Environment variables are set in render.yaml
2. Additional secrets via Render dashboard
3. Auto-deploy from main branch enabled

### 3. Database Setup (if needed)
1. Create Supabase project
2. Copy connection string
3. Add to GitHub environment secrets
4. Update Render environment variables

## ⚠️ Security Notes

- Never commit real secrets to repository
- Use GitHub environment secrets for sensitive data
- Rotate secrets regularly
- Use different secrets for staging/production

## 🔄 Deployment Flow

```
GitHub main branch → Render.com auto-deploy → Production API
```

1. Code pushed to main branch
2. GitHub triggers webhook to Render
3. Render builds and deploys automatically
4. API becomes available at production URL

---

*Environment: Production*  
*Platform: Render.com*  
*Status: Active & Operational*  
*Last Updated: June 7, 2025*
