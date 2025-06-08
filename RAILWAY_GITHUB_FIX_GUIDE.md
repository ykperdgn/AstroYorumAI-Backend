# 🚂 Railway GitHub Repository Connection Fix Guide

## 🚨 CURRENT ISSUE
**"Repo not found"** error in Railway dashboard means GitHub repository connection is broken.

## 🔍 SYMPTOMS DETECTED:
- ✅ Railway API is responding
- ✅ Railway CLI connected to project
- ❌ Deployed code shows "flatlib Swiss Ephemeris" (OLD VERSION)
- ❌ Should show "Skyfield Astronomical Library" (NEW VERSION)
- ❌ GitHub auto-deployment not working

## 🔧 MANUAL FIX STEPS (Do this NOW):

### Step 1: Access Railway Dashboard
1. Open browser: https://railway.app/dashboard
2. Login to your Railway account
3. Find project: **astroyorumai-backend**
4. Click on the project

### Step 2: Disconnect Repository
1. Go to **Settings** tab (in left sidebar)
2. Scroll down to **Source** section
3. If repository is connected, click **"Disconnect"**
4. Confirm disconnection

### Step 3: Reconnect GitHub Repository
1. In **Source** section, click **"Connect GitHub Repository"**
2. Click **"Authorize Railway"** (if prompted)
3. In repository list, find and select: **AstroYorumAI**
4. Select branch: **main**
5. Enable **"Auto Deploy"** checkbox
6. Click **"Connect"**

### Step 4: Trigger Deployment
1. After connecting, Railway should auto-deploy
2. OR click **"Deploy"** button manually
3. OR go to **Deployments** tab and click **"Deploy from main"**

### Step 5: Verification
Wait 3-5 minutes for deployment, then test:

```powershell
# Test command (run in PowerShell)
python -c "import requests; r = requests.get('https://astroyorumai-backend-production.up.railway.app/health'); data = r.json(); print(f'Method: {data[\"calculation_method\"]}'); print('SUCCESS: Skyfield detected!' if 'skyfield' in data['calculation_method'].lower() else 'FAILED: Still old version')"
```

**Expected Result:**
- Should show: `"calculation_method": "Skyfield Astronomical Library"`
- Should NOT show: `"flatlib Swiss Ephemeris"`

## 🎯 WHY THIS MATTERS:

### ❌ Current State (Broken):
- GitHub pushes don't trigger Railway deployments
- Old flatlib code running (compilation errors)
- Manual Railway CLI deployment required each time

### ✅ Fixed State (Working):
- GitHub pushes automatically deploy to Railway
- New skyfield code running (no compilation errors)  
- Zero-touch deployment pipeline

## 🚀 ALTERNATIVE: Manual Deployment

If GitHub connection fails, use Railway CLI:

```bash
# In project directory
railway login
railway link
railway up
```

## 📋 STATUS CHECKLIST:

### Before Fix:
- [ ] Railway API responding
- [ ] Old flatlib code deployed
- [ ] "Repo not found" in dashboard
- [ ] Manual deployment required

### After Fix:
- [ ] Railway API responding  
- [ ] New skyfield code deployed
- [ ] GitHub repository connected
- [ ] Auto-deployment working

## 🔄 DEPLOYMENT VERIFICATION:

### Test 1: Health Check
```bash
curl https://astroyorumai-backend-production.up.railway.app/health
```

### Test 2: Natal Chart (Critical)
```bash
curl -X POST https://astroyorumai-backend-production.up.railway.app/natal \
  -H "Content-Type: application/json" \
  -d '{"date":"1990-06-15","time":"14:30","latitude":41.0082,"longitude":28.9784}'
```

## 🎉 SUCCESS CRITERIA:

1. **✅ Repository Connected**: No "repo not found" error
2. **✅ Auto-Deploy Working**: GitHub pushes trigger Railway builds  
3. **✅ Skyfield Code Live**: API returns "Skyfield Astronomical Library"
4. **✅ All Endpoints Working**: Natal, synastry, transit endpoints respond
5. **✅ CORS Configured**: Flutter app can connect successfully

---

## 🚨 ACTION REQUIRED NOW:

**👉 Go to Railway Dashboard and reconnect GitHub repository**
**⏰ This takes 5 minutes and fixes the deployment pipeline**

Railway Dashboard: https://railway.app/dashboard
Project: astroyorumai-backend
