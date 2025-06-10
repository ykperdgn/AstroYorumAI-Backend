# AstroYorumAI Phase 3 Railway Deployment Script
# Run this script to deploy backend to Railway.app

Write-Host "AstroYorumAI Phase 3 - Railway.app Deployment" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Check if Railway CLI is installed
if (-not (Get-Command railway -ErrorAction SilentlyContinue)) {
    Write-Host "Railway CLI not found. Installing..." -ForegroundColor Red
    Write-Host "Please install Railway CLI first:" -ForegroundColor Yellow
    Write-Host "npm install -g @railway/cli" -ForegroundColor Yellow
    Write-Host "or download from: https://railway.app/cli" -ForegroundColor Yellow
    exit 1
}

Write-Host "Railway CLI found" -ForegroundColor Green

# Login to Railway
Write-Host "Logging into Railway..." -ForegroundColor Yellow
railway login

# Initialize project
Write-Host "Initializing Railway project..." -ForegroundColor Yellow
railway init astroyorumai-backend --name "AstroYorumAI Backend"

# Add PostgreSQL database
Write-Host "Adding PostgreSQL database..." -ForegroundColor Yellow
railway add postgresql

# Set environment variables
Write-Host "Setting environment variables..." -ForegroundColor Yellow
railway variables set FLASK_ENV=production
railway variables set FLASK_DEBUG=False
railway variables set API_VERSION=2.1.3

# Deploy to Railway
Write-Host "Deploying to Railway..." -ForegroundColor Yellow
railway up

Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Your API will be available at the Railway-provided URL" -ForegroundColor Cyan
Write-Host "Check deployment status at: https://railway.app/dashboard" -ForegroundColor Cyan
