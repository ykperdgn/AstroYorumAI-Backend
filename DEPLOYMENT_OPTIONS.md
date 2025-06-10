# Quick Deployment Guide - AstroYorumAI API

## Option 1: Render.com (Recommended - Free & Easy)

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

### 2. Deploy on Render
1. Go to [render.com](https://render.com)
2. Sign up with GitHub account
3. Click "New" → "Web Service"
4. Connect your GitHub repository
5. Configure:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn astro_api:app`
   - **Environment**: Python 3
   - **Plan**: Free

### 3. Environment Variables
Add in Render dashboard:
- `FLASK_ENV=production`
- `PORT=10000` (Render default)

### Your API will be live at:
`https://astroyorumai-api.onrender.com`

## Option 2: PythonAnywhere (Alternative)

### 1. Create Account
- Go to [pythonanywhere.com](https://pythonanywhere.com)
- Create free account

### 2. Upload Files
- Use file manager to upload your Python files
- Upload: astro_api.py, requirements.txt, Procfile

### 3. Create Web App
- Go to Web tab
- Create new web app
- Choose Flask
- Configure WSGI file

## Option 3: Railway (If Node.js available)

```bash
# Install Railway CLI
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
