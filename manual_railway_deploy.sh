#!/bin/bash
# Railway Manual Deployment Script

echo "🚂 Railway Manual Deployment"
echo "============================"

# Check Railway CLI
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
fi

# Login to Railway
echo "🔐 Logging in to Railway..."
railway login

# Link to project
echo "🔗 Linking to project..."
railway link

# Deploy current code
echo "🚀 Deploying to Railway..."
railway up

echo "✅ Deployment completed!"
echo "🌐 Check: https://astroyorumai-backend-production.up.railway.app/health"
