# 🚀 GitHub Production Environment Setup - Step by Step

## 🎯 Objective
Create a new "production" environment in GitHub with proper secrets configuration for Render.com deployment.

## 📋 Prerequisites
- ✅ GitHub repository: AstroYorumAI
- ✅ Production API running: https://astroyorumai-api.onrender.com
- ✅ Render.com service deployed and working
- ✅ Railway references cleaned from codebase

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
Choose one option and add the secret:

```bash
# Option 1: Supabase (Recommended - Free 500MB)
Name: DATABASE_URL
Value: postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

# Option 2: Render PostgreSQL (Paid)
Name: DATABASE_URL  
Value: postgresql://[user]:[password]@[host]/[database]

# Option 3: PlanetScale (Free 5GB MySQL)
Name: DATABASE_URL
Value: mysql://[username]:[password]@[host]/[database]?sslmode=require
```

#### 🌐 CORS & Security Configuration
```bash
Name: CORS_ORIGINS
Value: https://astroyorumai.com,https://www.astroyorumai.com,https://astroyorumai-api.onrender.com

Name: ALLOWED_HOSTS
Value: astroyorumai.com,www.astroyorumai.com,astroyorumai-api.onrender.com
```

#### ⚡ Performance Optimization
```bash
Name: WEB_CONCURRENCY
Value: 1

Name: ENABLE_KEEP_ALIVE
Value: true

Name: KEEP_ALIVE_URL
Value: https://astroyorumai-api.onrender.com/health

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

## 🔄 Render.com Integration

### Render.com Environment Variables Setup
After creating GitHub environment, also add these to Render.com:

```
1. Go to https://dashboard.render.com
2. Select your service: astroyorumai-api
3. Click "Environment" tab
4. Add environment variables:
```

#### Core Variables for Render.com
```bash
SECRET_KEY = [same as GitHub secret]
FLASK_ENV = production
FLASK_DEBUG = False
PORT = 5000
DATABASE_URL = [your chosen database URL]
CORS_ORIGINS = https://astroyorumai.com,https://www.astroyorumai.com,https://astroyorumai-api.onrender.com
WEB_CONCURRENCY = 1
PYTHONUNBUFFERED = 1
ENABLE_KEEP_ALIVE = true
KEEP_ALIVE_URL = https://astroyorumai-api.onrender.com/health
```

## 🧪 Testing Environment Configuration

### Test 1: API Health Check
```powershell
# PowerShell command to test API
Invoke-WebRequest -Uri "https://astroyorumai-api.onrender.com/health" -Method GET | ConvertFrom-Json
```

Expected Response:
```json
{
  "status": "healthy",
  "version": "2.1.3-real-calculations",
  "service": "AstroYorumAI API",
  "python_version": "3.11.11",
  "calculation_method": "flatlib Swiss Ephemeris"
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

Invoke-WebRequest -Uri "https://astroyorumai-api.onrender.com/natal" -Method POST -Body $body -ContentType "application/json"
```

### Test 3: All Endpoints Status
```powershell
# Test all 9 endpoints
$endpoints = @("/health", "/status", "/natal", "/synastry", "/transit", "/solar-return", "/progression", "/horary", "/composite")

foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-WebRequest -Uri "https://astroyorumai-api.onrender.com$endpoint" -Method GET
        Write-Host "✅ $endpoint - Status: $($response.StatusCode)"
    } catch {
        Write-Host "❌ $endpoint - Error: $($_.Exception.Message)"
    }
}
```

## 📱 Flutter App Configuration Update

Update your Flutter app to use production environment:

### Update API Base URL
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String baseUrl = 'https://astroyorumai-api.onrender.com';
  static const bool isProduction = true;
  static const String environment = 'production';
}
```

### Update CORS Configuration
```dart
// Make sure your HTTP requests include proper headers
final response = await http.post(
  Uri.parse('${AppConfig.baseUrl}/natal'),
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

### Access Control
- [ ] Environment is protected with branch restrictions
- [ ] Only main branch can trigger deployments
- [ ] Secrets are not logged or exposed
- [ ] Environment variables are properly configured in Render.com

## 🎯 Deployment Workflow

### Automatic Deployment Process
```
1. Code pushed to main branch
2. GitHub webhook triggers Render.com build
3. Render.com pulls latest code from GitHub
4. Environment variables injected from Render dashboard
5. Docker build process with production configuration
6. New deployment goes live automatically
7. Health checks verify deployment success
```

### Manual Deployment (if needed)
```
1. Go to Render.com dashboard
2. Select astroyorumai-api service
3. Click "Manual Deploy" button
4. Select branch: main
5. Click "Deploy Latest Commit"
```

## 📈 Monitoring & Maintenance

### Health Monitoring
```powershell
# Create a simple monitoring script
$healthUrl = "https://astroyorumai-api.onrender.com/health"
$response = Invoke-WebRequest -Uri $healthUrl -Method GET
$data = $response.Content | ConvertFrom-Json

Write-Host "API Status: $($data.status)"
Write-Host "Version: $($data.version)"
Write-Host "Response Time: $($response.Headers['Response-Time']) ms"
```

### Performance Monitoring
- Response time monitoring via Render.com dashboard
- Error rate tracking via application logs
- Memory and CPU usage monitoring
- Database connection monitoring

## 🎉 Environment Setup Complete!

### Verification Checklist
- [ ] GitHub "production" environment created
- [ ] All required secrets added to GitHub environment
- [ ] Render.com environment variables configured
- [ ] API health check passing
- [ ] CORS working for production domains
- [ ] All 9 endpoints responding correctly
- [ ] Flutter app configured for production
- [ ] Security measures in place
- [ ] Monitoring configured

### Next Steps
1. **Database Setup**: Choose and configure production database
2. **Custom Domain**: Configure custom domain (optional)
3. **SSL Certificate**: Verify HTTPS configuration
4. **Phase 3 Preparation**: Set up Stripe and OpenAI when ready
5. **Beta Testing**: Begin user testing with production environment

---

**🚀 Status**: Production environment ready for deployment!
**📅 Date**: June 7, 2025
**🔗 Live API**: https://astroyorumai-api.onrender.com
**🎯 Environment**: production (GitHub)
