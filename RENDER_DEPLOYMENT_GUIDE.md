# 🚀 Render.com Deployment Guide for AstroYorumAI

## 📋 Environment Setup Complete

### ✅ Updated Files
- `.env.render` - Render-specific production environment
- `.env.development` - Clean development environment  
- `.env.example` - Updated example with clear instructions
- `.env.production` - Updated production environment
- `render.yaml` - Optimized Render Blueprint configuration

### ✅ Railway Cleanup Complete
- All Railway references removed
- Environment variables updated for Render
- Clean codebase ready for new deployment

## 🔧 Deployment Steps
1. Go to [Render.com](https://render.com)
2. Sign in/Sign up with your GitHub account
3. Click "New +" and select "Web Service"
4. Connect your GitHub repository: `https://github.com/ykperdgn/AstroYorumAI-Backend`
5. Configure the service:
   - **Name**: `astroyorumai-api`
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn astro_api:app`
   - **Plan**: `Free`

## Step 2: Environment Variables
Add these environment variables in Render.com dashboard:
- `FLASK_ENV` = `production`
- `PORT` = `10000` (Render's default)

## Step 3: Verification URLs
Once deployed, test these URLs:
- Health Check: `https://astroyorumai-api.onrender.com/health`
- Root: `https://astroyorumai-api.onrender.com/`
- API Documentation: `https://astroyorumai-api.onrender.com/`

## Step 4: Test API Endpoint
```bash
curl -X POST https://astroyorumai-api.onrender.com/natal \
  -H "Content-Type: application/json" \
  -d '{
    "date": "1990-01-01",
    "time": "12:00",
    "latitude": 41.0082,
    "longitude": 28.9784
  }'
```

## Alternative: Direct Deploy Button
If render.yaml isn't working, you can:
1. Delete render.yaml from the repository
2. Use Render's auto-detection
3. Manually configure in the dashboard

## Common Issues & Solutions

### Issue: 404 Not Found
- **Cause**: Service not deployed or wrong URL
- **Solution**: Check Render dashboard for deployment status

### Issue: Build Failed
- **Cause**: Missing dependencies or Python version mismatch
- **Solution**: Check build logs in Render dashboard

### Issue: Service Sleeping
- **Cause**: Free tier services sleep after 15 minutes of inactivity
- **Solution**: First request might take 30-60 seconds to wake up

### Issue: Wrong Start Command
- **Cause**: Procfile or start command incorrect
- **Solution**: Ensure `gunicorn astro_api:app` is the start command

## Files Required for Deployment
✅ `astro_api.py` - Main Flask application
✅ `requirements.txt` - Python dependencies
✅ `Procfile` - Process configuration
✅ `render.yaml` - Render configuration (optional)

## Next Steps After Successful Deployment
1. Update Flutter app with the correct production URL
2. Test all API endpoints from the Flutter app
3. Set up Firebase production environment
4. Prepare for beta testing

## Contact Info
If deployment issues persist, check:
- Render.com build logs
- GitHub Actions (if configured)
- Service health status in Render dashboard
