#!/bin/bash
# Railway Deployment Script for AstroYorumAI Backend

echo "🚂 Starting Railway deployment..."

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
fi

# Login to Railway (if not already logged in)
echo "🔑 Checking Railway authentication..."
railway whoami 2>/dev/null || railway login

# Link to existing project or create new one
echo "🔗 Linking to Railway project..."
if [ ! -f ".railway" ]; then
    echo "Creating new Railway project..."
    railway new
else
    echo "Using existing Railway project..."
fi

# Set environment variables
echo "⚙️ Setting environment variables..."
railway variables set FLASK_ENV=production
railway variables set PYTHONUNBUFFERED=1
railway variables set API_VERSION=2.1.3-railway
railway variables set CORS_ORIGINS="https://astroyorumai.com,https://www.astroyorumai.com"
railway variables set HOST=0.0.0.0
railway variables set PORT=8080

# Deploy to Railway
echo "🚀 Deploying to Railway..."
railway up --detach

echo "✅ Railway deployment initiated!"
echo "📊 Monitor deployment at: https://railway.app/dashboard"
echo "🌐 Your app will be available at: https://[project-name].up.railway.app"
