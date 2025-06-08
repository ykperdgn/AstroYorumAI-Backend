# Railway GitHub Connection Fix Script
# Run this script to fix "Repo not found" issue

Write-Host "Railway GitHub Connection Fix" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Step 1: Check Git repository status
Write-Host "`n1. Checking Git repository status..." -ForegroundColor Yellow
try {
    $gitStatus = git status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Git repository is valid" -ForegroundColor Green
        git remote -v
    } else {
        Write-Host "❌ Git repository issue: $gitStatus" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Git not available: $_" -ForegroundColor Red
}

# Step 2: Check Railway CLI
Write-Host "`n2. Checking Railway CLI..." -ForegroundColor Yellow
try {
    $railwayVersion = railway --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Railway CLI available: $railwayVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ Railway CLI issue: $railwayVersion" -ForegroundColor Red
        Write-Host "Installing Railway CLI..." -ForegroundColor Yellow
        npm install -g @railway/cli
    }
} catch {
    Write-Host "❌ Railway CLI not available: $_" -ForegroundColor Red
}

# Step 3: Manual deployment preparation
Write-Host "`n3. Preparing manual deployment..." -ForegroundColor Yellow

# Create deployment zip
$zipPath = "railway-deployment.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Files to include in deployment
$filesToInclude = @(
    "app.py",
    "requirements.txt",
    "railway.toml",
    "nixpacks.toml",
    "Procfile"
)

Write-Host "Creating deployment package..." -ForegroundColor Yellow
foreach ($file in $filesToInclude) {
    if (Test-Path $file) {
        Write-Host "✅ Including: $file" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Missing: $file" -ForegroundColor Yellow
    }
}

# Instructions for manual fix
Write-Host "`n🔧 MANUAL FIX STEPS:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "1. Go to Railway Dashboard: https://railway.app/dashboard" -ForegroundColor White
Write-Host "2. Select your AstroYorumAI project" -ForegroundColor White
Write-Host "3. Go to Settings > Source" -ForegroundColor White
Write-Host "4. Click 'Disconnect' if repository is connected" -ForegroundColor White
Write-Host "5. Click 'Connect GitHub Repository'" -ForegroundColor White
Write-Host "6. Authorize Railway to access your GitHub" -ForegroundColor White
Write-Host "7. Select AstroYorumAI repository" -ForegroundColor White
Write-Host "8. Select 'main' branch" -ForegroundColor White
Write-Host "9. Enable 'Auto Deploy' option" -ForegroundColor White

Write-Host "`n🚀 ALTERNATIVE: Manual Deploy" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "If GitHub connection fails, use Railway CLI:" -ForegroundColor White
Write-Host "1. railway login" -ForegroundColor Gray
Write-Host "2. railway link" -ForegroundColor Gray
Write-Host "3. railway up" -ForegroundColor Gray

Write-Host "`n📋 CURRENT DEPLOYMENT STATUS" -ForegroundColor Magenta
Write-Host "=============================" -ForegroundColor Magenta
try {
    $response = Invoke-WebRequest -Uri "https://astroyorumai-backend-production.up.railway.app/health" -Method GET -TimeoutSec 10
    $data = $response.Content | ConvertFrom-Json
    Write-Host "✅ API is live and responding" -ForegroundColor Green
    Write-Host "   Status: $($data.status)" -ForegroundColor White
    Write-Host "   Version: $($data.version)" -ForegroundColor White
    Write-Host "   Method: $($data.calculation_method)" -ForegroundColor White
} catch {
    Write-Host "❌ API not responding: $_" -ForegroundColor Red
    Write-Host "   This confirms the deployment issue." -ForegroundColor Yellow
}

Write-Host "`n🎯 PRIORITY ACTIONS:" -ForegroundColor Red
Write-Host "===================" -ForegroundColor Red
Write-Host "1. Fix GitHub repository connection in Railway dashboard" -ForegroundColor White
Write-Host "2. Verify repository URL: https://github.com/[username]/AstroYorumAI" -ForegroundColor White
Write-Host "3. Ensure repository is public or Railway has access" -ForegroundColor White
Write-Host "4. Test deployment after connection is fixed" -ForegroundColor White

Write-Host "`nScript completed. Please follow the manual steps above." -ForegroundColor Green
