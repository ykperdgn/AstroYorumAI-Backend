# 🚂 Railway.app Deployment Guide for AstroYorumAI

## 📋 Environment Setup Complete

### ✅ Updated Files
- `.env.railway` - Railway-specific production environment
- `.env.development` - Clean development environment  
- `.env.example` - Updated example with clear instructions
- `.env.production` - Updated production environment
- `railway.toml` - Railway Blueprint configuration
- `railway.json` - Railway project configuration

### ✅ Render.com Cleanup Complete
- All Render.com references removed
- Environment variables updated for Railway
- Clean codebase ready for new deployment

---

## 🚂 Quick Deployment (5 minutes)

### Step 1: Install Railway CLI
```bash
npm install -g @railway/cli
```

### Step 2: Deploy
```bash
# Login to Railway
railway login

# Create new project or link existing
railway new

# Deploy current directory
railway up
```

### Step 3: Environment Variables
Add these environment variables in Railway dashboard:

```bash
FLASK_ENV=production
FLASK_DEBUG=false
SECRET_KEY=railway-production-secret-key-2024
HOST=0.0.0.0
PORT=8080
API_VERSION=2.1.3-railway
CORS_ORIGINS=https://astroyorumai.com,https://www.astroyorumai.com
PYTHONUNBUFFERED=1
```

---

## 🎯 Verification

Your API will be live at:
- Health Check: `https://[project-name].up.railway.app/health`
- Root: `https://[project-name].up.railway.app/`
- API Documentation: `https://[project-name].up.railway.app/`

### Test with curl:
```bash
curl -X POST https://[project-name].up.railway.app/natal \
  -H "Content-Type: application/json" \
  -d '{
    "birth_date": "1990-05-15",
    "birth_time": "10:30",
    "birth_place": "Istanbul",
    "latitude": 41.0082,
    "longitude": 28.9784
  }'
```

---

## 🎛️ Advanced Configuration

### 1. Custom Domain (Optional)
```bash
railway domain add your-domain.com
```

### 2. Database (PostgreSQL)
```bash
railway add postgresql
```

### 3. Environment Variables via CLI
```bash
railway variables set OPENAI_API_KEY=your_key_here
railway variables set STRIPE_SECRET_KEY=your_stripe_key
```

### 4. Monitoring
```bash
railway logs
railway status
```

---

## 🔍 Troubleshooting

### Common Issues:
1. **Build Failed**: Check `requirements.txt` and Python version
2. **Port Error**: Ensure PORT is set to Railway's provided value
3. **CORS Issues**: Update CORS_ORIGINS with Railway domain

### Debug Commands:
```bash
railway logs
railway shell
railway status
```

---

## 📊 Railway vs Other Platforms

| Feature | Railway | Render | Heroku |
|---------|---------|--------|---------|
| **Free Tier** | $5/month usage | Free with limits | No free tier |
| **Auto Deploy** | ✅ GitHub integration | ✅ GitHub integration | ✅ GitHub integration |
| **Custom Domains** | ✅ Free | ✅ Free | ✅ Paid plans |
| **PostgreSQL** | ✅ Built-in | ✅ Built-in | ✅ Add-on |
| **Build Speed** | 🚀 Fast | 🐢 Slower | 🚀 Fast |

---

## ✅ Complete Setup Checklist

- [ ] Railway CLI installed
- [ ] Railway account created with GitHub
- [ ] Project deployed successfully
- [ ] Environment variables configured
- [ ] Health check passing
- [ ] API endpoints tested
- [ ] Domain configured (optional)
- [ ] Database connected (if needed)

---

**Ready for deployment!** 🚀

Your Flask API is optimized for Railway.app deployment with proper environment handling, CORS configuration, and health checks.

**Next Step**: Run `railway up` in your project directory
