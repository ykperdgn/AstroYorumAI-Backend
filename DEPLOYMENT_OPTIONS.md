# Quick Deployment Guide - AstroYorumAI API

## Option 1: Railway.app (Recommended - Fast & Reliable)

### 1. GitHub Repository Setup
```bash
# Initialize git if not already done
git init
git add .
git commit -m "Initial commit for deployment"

# Create GitHub repository and push
# Go to github.com and create new repository: astroyorumai-api
git remote add origin https://github.com/YOUR_USERNAME/astroyorumai-api.git
git push -u origin main
```

### 2. Deploy on Railway
1. Go to [railway.app](https://railway.app)
2. Sign up with GitHub account
3. Click "New Project" → "Deploy from GitHub repo"
4. Connect your GitHub repository
5. Configure:
   - **Build Command**: Automatic (Nixpacks detects Python)
   - **Start Command**: `gunicorn app:app`
   - **Environment**: Python 3
   - **Plan**: Usage-based pricing

### 3. Environment Variables
Add in Railway dashboard:
- `FLASK_ENV=production`
- `PORT=8080` (Railway default)

### Your API will be live at:
`https://astroyorumai-backend-production.up.railway.app`

## Option 2: PythonAnywhere (Alternative)

### 1. Create Account
- Go to [pythonanywhere.com](https://pythonanywhere.com)
- Create free account

### 2. Upload Files
- Use file manager to upload your Python files
- Upload: app.py, requirements.txt, Procfile

### 3. Create Web App
- Go to Web tab
- Create new web app
- Choose Flask
- Configure WSGI file

## Option 3: Render.com (Alternative - Free Tier)

```bash
# For comparison - Render.com setup
npm install -g @railway/cli

# Deploy
railway login
railway new
railway up
```

## Option 4: Vercel (Serverless)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

## Current Status
- ✅ Flask API ready
- ✅ Requirements.txt created
- ✅ Procfile created
- ⏳ Deployment platform selection

## Next Steps
1. Choose deployment platform (Render recommended)
2. Create GitHub repository
3. Deploy and get production URL
4. Update Flutter app with production API endpoint
