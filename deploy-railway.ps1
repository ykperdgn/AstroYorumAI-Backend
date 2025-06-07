# Railway Deployment Script for AstroYorumAI Backend
# PowerShell Version

Write-Host "🚂 Starting Railway deployment..." -ForegroundColor Green

# Check if Railway CLI is installed
try {
    railway --version | Out-Null
    Write-Host "✅ Railway CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ Railway CLI not found. Installing..." -ForegroundColor Red
    npm install -g @railway/cli
}

# Login to Railway (if not already logged in)
Write-Host "🔑 Checking Railway authentication..." -ForegroundColor Yellow
try {
    railway whoami | Out-Null
    Write-Host "✅ Already authenticated" -ForegroundColor Green
} catch {
    Write-Host "🔐 Please authenticate with Railway..." -ForegroundColor Yellow
    railway login
}

# Link to existing project or create new one
Write-Host "🔗 Linking to Railway project..." -ForegroundColor Yellow
if (!(Test-Path ".railway")) {
    Write-Host "Creating new Railway project..." -ForegroundColor Cyan
    railway new
} else {
    Write-Host "Using existing Railway project..." -ForegroundColor Green
}

# Set environment variables
Write-Host "⚙️ Setting environment variables..." -ForegroundColor Yellow
railway variables set FLASK_ENV=production
railway variables set PYTHONUNBUFFERED=1
railway variables set API_VERSION=2.1.3-railway
railway variables set CORS_ORIGINS="https://astroyorumai.com,https://www.astroyorumai.com"
railway variables set HOST=0.0.0.0
railway variables set PORT=8080

# Deploy to Railway
Write-Host "🚀 Deploying to Railway..." -ForegroundColor Green
railway up --detach

Write-Host "✅ Railway deployment initiated!" -ForegroundColor Green
Write-Host "📊 Monitor deployment at: https://railway.app/dashboard" -ForegroundColor Cyan
Write-Host "🌐 Your app will be available at: https://[project-name].up.railway.app" -ForegroundColor Cyan
