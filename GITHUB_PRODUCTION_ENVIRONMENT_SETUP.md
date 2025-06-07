# 🚂 GitHub Production Environment Setup for Railway - Complete Guide

## 🎯 Objective
Create a new "production" environment in GitHub with proper secrets configuration for Railway.app deployment.

## 📋 Prerequisites
- ✅ GitHub repository: AstroYorumAI
- ✅ Railway account created (railway.app)
- ✅ Railway CLI installed (`npm install -g @railway/cli`)
- ✅ Railway deployment files ready (railway.toml, railway.json)
- ✅ Migration from Render.com completed

## 🔧 Step-by-Step GitHub Environment Setup

### Step 1: Access GitHub Repository Settings
```
1. Go to your GitHub repository
2. Click "Settings" tab (top right of repository page)
3. Scroll down to "Code and automation" section in left sidebar
4. Click "Environments"
```

### Step 2: Create New Production Environment
```
1. Click "New environment" button
2. Environment name: "production"
3. Click "Configure environment"
```

### Step 3: Configure Environment Protection Rules (Optional)
```
Environment protection rules:
□ Required reviewers: None (for solo project)
□ Wait timer: 0 minutes
☑ Deployment branches: Selected branches
   - Add rule: main (only main branch can deploy)
```

### Step 4: Add Environment Secrets
Click "Add secret" for each of these:

#### 🔐 Core Application Secrets
```bash
Name: SECRET_KEY
Value: your-secure-256-bit-production-secret-key-here

Name: FLASK_ENV
Value: production

Name: FLASK_DEBUG
Value: False

Name: PORT
Value: 5000

Name: HOST
Value: 0.0.0.0
```

#### 🗄️ Database Configuration
```bash
# Railway PostgreSQL (Recommended - Built-in)
Name: DATABASE_URL
Value: postgresql://postgres:[password]@[host]:5432/railway

# Alternative Options:
# Supabase (Free 500MB)
# Name: DATABASE_URL
# Value: postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

# PlanetScale (Free 5GB MySQL)
# Name: DATABASE_URL  
# Value: mysql://[username]:[password]@[host]/[database]?sslmode=require
```

#### 🌐 CORS & Security Configuration
```bash
Name: CORS_ORIGINS
Value: https://astroyorumai.com,https://www.astroyorumai.com,https://astroyorumai-backend-production.up.railway.app

Name: ALLOWED_HOSTS
Value: astroyorumai.com,www.astroyorumai.com,astroyorumai-backend-production.up.railway.app
```

#### ⚡ Performance Optimization
```bash
Name: WEB_CONCURRENCY
Value: 1

Name: ENABLE_KEEP_ALIVE
Value: true

Name: KEEP_ALIVE_URL
Value: https://astroyorumai-backend-production.up.railway.app/health

Name: PYTHONUNBUFFERED
Value: 1
```

#### 💳 Payment Integration (Phase 3 - Add Later)
```bash
# Stripe Test Keys (for development)
Name: STRIPE_TEST_PUBLISHABLE_KEY
Value: pk_test_your_test_publishable_key

Name: STRIPE_TEST_SECRET_KEY
Value: sk_test_your_test_secret_key

# Stripe Live Keys (when ready for production)
Name: STRIPE_PUBLISHABLE_KEY
Value: pk_live_your_live_publishable_key

Name: STRIPE_SECRET_KEY
Value: sk_live_your_live_secret_key

Name: STRIPE_WEBHOOK_SECRET
Value: whsec_your_webhook_secret
```

#### 🤖 AI Integration (Phase 3 - Add Later)
```bash
Name: OPENAI_API_KEY
Value: sk-your_openai_api_key_here

Name: OPENAI_ORG_ID
Value: org-your_organization_id
```

#### 📊 Monitoring & Analytics (Optional)
```bash
Name: SENTRY_DSN
Value: https://your_sentry_dsn_here

Name: GA_TRACKING_ID
Value: G-SPBQSQB0K8

Name: FIREBASE_PROJECT_ID
Value: astroyorumai-production
```

## 🚂 Railway Integration & Secrets

### Railway Environment Variables Setup
After creating GitHub environment, configure Railway deployment:

#### Step 1: Railway CLI Login & Setup
```bash
# Install Railway CLI if not installed
npm install -g @railway/cli

# Login to Railway
railway login

# Link to existing project or create new
railway link
# OR
railway new AstroYorumAI-Backend
```

#### Step 2: Add Railway Environment Variables
```bash
# Core application variables
railway variables set SECRET_KEY="your-secure-256-bit-production-secret-key-here"
railway variables set FLASK_ENV="production"
railway variables set FLASK_DEBUG="False"
railway variables set PORT="5000"
railway variables set HOST="0.0.0.0"

# Database (Railway provides PostgreSQL)
railway add postgresql
# DATABASE_URL will be automatically set

# CORS & Security
railway variables set CORS_ORIGINS="https://astroyorumai.com,https://www.astroyorumai.com,https://astroyorumai-backend-production.up.railway.app"
railway variables set ALLOWED_HOSTS="astroyorumai.com,www.astroyorumai.com,astroyorumai-backend-production.up.railway.app"

# Performance
railway variables set WEB_CONCURRENCY="1"
railway variables set PYTHONUNBUFFERED="1"
railway variables set ENABLE_KEEP_ALIVE="true"
railway variables set KEEP_ALIVE_URL="https://astroyorumai-backend-production.up.railway.app/health"
```

#### Step 3: Deploy to Railway
```bash
# Deploy current branch
railway up

# Check deployment status
railway status

# View logs
railway logs

# Get deployment URL
railway domain
```

## 🧪 Testing Railway Deployment

### Test 1: API Health Check
```powershell
# PowerShell command to test Railway API
Invoke-WebRequest -Uri "https://astroyorumai-backend-production.up.railway.app/health" -Method GET | ConvertFrom-Json
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

### Test 2: Natal Chart Calculation
```powershell
# Test natal chart endpoint
$body = @{
    date = "1990-06-15"
    time = "14:30" 
    latitude = 41.0082
    longitude = 28.9784
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://astroyorumai-backend-production.up.railway.app/natal" -Method POST -Body $body -ContentType "application/json"
```

### Test 3: All Endpoints Status
```powershell
python verify_railway_deployment.py
```

## 📱 Flutter App Configuration Update

Update your Flutter app to use Railway production environment:

### Update API Base URL
```dart
// lib/config/app_environment.dart - Already updated
class AppEnvironment {
  static String get baseUrl => 'https://astroyorumai-backend-production.up.railway.app';
  static const bool isProduction = true;
  static const String environment = 'production';
  static const String platform = 'Railway';
}
```

### Update CORS Configuration
```dart
// Make sure your HTTP requests include proper headers
final response = await http.post(
  Uri.parse('${AppEnvironment.baseUrl}/natal'),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  body: jsonEncode(requestData),
);
```

## 🚨 Security Checklist

### Environment Security
- [ ] All secrets are stored in GitHub environment (not in code)
- [ ] Production secrets are different from development
- [ ] Database credentials are secure and rotated
- [ ] API keys have proper permissions and limits
- [ ] CORS is configured for production domains only

### Railway Security
- [ ] Railway project has proper access controls
- [ ] Environment variables are properly secured in Railway dashboard
- [ ] Database access is restricted to Railway network
- [ ] Custom domain configured with SSL/TLS

## 🎯 Railway Deployment Workflow

### Automatic Deployment Process
```
1. Code pushed to main branch
2. GitHub webhook triggers Railway build
3. Railway pulls latest code from GitHub
4. Environment variables injected from Railway dashboard
5. Nixpacks/Docker build process with production configuration
6. New deployment goes live automatically with zero downtime
7. Health checks verify deployment success (/health endpoint)
```

### Manual Deployment (if needed)
```bash
# Using Railway CLI
railway login
railway link [project-id]
railway up

# Or via Railway dashboard
1. Go to railway.app dashboard
2. Select AstroYorumAI-Backend project
3. Click "Deploy" button
4. Select branch: main
5. Railway will build and deploy automatically
```

## 📈 Monitoring & Maintenance

### Health Monitoring
```powershell
# Create a Railway monitoring script
$healthUrl = "https://astroyorumai-backend-production.up.railway.app/health"
$response = Invoke-WebRequest -Uri $healthUrl -Method GET
$data = $response.Content | ConvertFrom-Json

Write-Host "API Status: $($data.status)"
Write-Host "Version: $($data.version)"
Write-Host "Platform: $($data.platform)"
Write-Host "Response Time: $($response.Headers['Response-Time']) ms"
```

### Railway Monitoring Dashboard
```
1. Railway provides built-in monitoring:
   - CPU usage
   - Memory usage
   - Network traffic
   - Request logs
   - Error tracking

2. Access via: railway.app dashboard > Your Project > Metrics
```

### Performance Monitoring
```bash
# Railway Performance Monitoring
1. Railway Dashboard Metrics:
   - Real-time CPU usage
   - Memory consumption
   - Request volume
   - Response times
   - Error rates
   - Build times

2. Application Logs:
   railway logs --follow

3. Resource Usage:
   railway status
```

### Railway Advanced Features
```bash
# Auto-scaling (available on Pro plan)
railway projects settings

# Custom domains
railway domain add astroyorumai-api.com

# Environment management
railway environments

# Database management
railway run psql $DATABASE_URL
```

## 🎉 Railway Environment Setup Complete!

### Verification Checklist
- [ ] GitHub "production" environment created
- [ ] All required secrets added to GitHub environment
- [ ] Railway project configured and deployed
- [ ] Railway environment variables set
- [ ] API health check passing on Railway URL
- [ ] CORS working for production domains
- [ ] All 9 endpoints responding correctly
- [ ] Flutter app configured for Railway production
- [ ] Security measures in place
- [ ] Railway monitoring configured

### Railway Deployment Benefits
✅ **Zero Downtime Deployments**: Railway handles rolling deployments  
✅ **Built-in PostgreSQL**: Managed database with automatic backups  
✅ **Automatic SSL**: HTTPS enabled by default  
✅ **Environment Management**: Easy variable and secret management  
✅ **Real-time Monitoring**: Built-in metrics and logging  
✅ **Git Integration**: Direct GitHub repository connection  
✅ **Scalability**: Auto-scaling on higher plans  

### Next Steps
1. **Railway Deployment**: Execute `railway up` to deploy
2. **Database Setup**: Configure Railway PostgreSQL database
3. **Domain Configuration**: Set up custom domain (optional)
4. **Phase 3 Preparation**: Set up Stripe and OpenAI when ready
5. **Beta Testing**: Begin user testing with Railway production environment

---

**🚂 Status**: Railway production environment ready for deployment!  
**📅 Date**: December 2024  
**🔗 Live API**: https://astroyorumai-backend-production.up.railway.app  
**🎯 Environment**: production (Railway)  
**🛠️ Platform**: Railway.app
