# Deployment Validation Script for AstroYorumAI
# This script validates the deployment setup and runs tests to ensure everything is working correctly

Write-Host "🔍 AstroYorumAI Deployment Validation" -ForegroundColor Cyan
Write-Host "-------------------------------------" -ForegroundColor Cyan

# Function to check if a command exists
function Test-CommandExists {
    param (
        [string]$Command
    )
    
    $exists = $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
    return $exists
}

# Function to check if a file exists
function Test-FileExists {
    param (
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path $Path) {
        Write-Host "✅ $Description found: $Path" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ $Description missing: $Path" -ForegroundColor Red
        return $false
    }
}

# Check required tools
Write-Host "`n1. Checking required tools:" -ForegroundColor Yellow

$flutter_ok = Test-CommandExists "flutter"
if ($flutter_ok) {
    Write-Host "✅ Flutter is installed" -ForegroundColor Green
    flutter --version | Select-Object -First 1
} else {
    Write-Host "❌ Flutter is not installed" -ForegroundColor Red
}

$firebase_ok = Test-CommandExists "firebase"
if ($firebase_ok) {
    Write-Host "✅ Firebase CLI is installed" -ForegroundColor Green
    firebase --version
} else {
    Write-Host "❌ Firebase CLI is not installed. Install with: npm install -g firebase-tools" -ForegroundColor Red
}

$python_ok = Test-CommandExists "python"
if ($python_ok) {
    Write-Host "✅ Python is installed" -ForegroundColor Green
    python --version
} else {
    Write-Host "❌ Python is not installed" -ForegroundColor Red
}

# Check configuration files
Write-Host "`n2. Checking configuration files:" -ForegroundColor Yellow

$android_config = Test-FileExists "android/app/google-services.json" "Android Firebase config"
$ios_config = Test-FileExists "ios/Runner/GoogleService-Info.plist" "iOS Firebase config"
$firebase_json = Test-FileExists "firebase.json" "Firebase config"
$firebaserc = Test-FileExists ".firebaserc" "Firebase project config"

# Check GitHub workflows
Write-Host "`n3. Checking GitHub Actions workflows:" -ForegroundColor Yellow

$workflows_dir = ".github/workflows"
if (Test-Path $workflows_dir) {
    Write-Host "✅ GitHub workflows directory found" -ForegroundColor Green
    
    $workflow_files = Get-ChildItem -Path $workflows_dir -Filter "*.yml"
    foreach ($file in $workflow_files) {
        Write-Host "  - $($file.Name)" -ForegroundColor Green
    }
} else {
    Write-Host "❌ GitHub workflows directory missing" -ForegroundColor Red
}

# Run tests to validate deployment
Write-Host "`n4. Running validation tests:" -ForegroundColor Yellow

if ($flutter_ok) {
    Write-Host "Running Flutter tests (excluding integration tests)..." -ForegroundColor Cyan
    flutter test --exclude-tags=integration
}

if ($python_ok) {
    Write-Host "Running backend API tests..." -ForegroundColor Cyan
    if (Test-Path "comprehensive_api_test.py") {
        python comprehensive_api_test.py
    } else {
        Write-Host "❌ API test file not found" -ForegroundColor Red
    }
}

# Check deployment status
Write-Host "`n5. Checking deployment status:" -ForegroundColor Yellow

if ($firebase_ok -and $firebase_json) {
    Write-Host "Checking Firebase project status..." -ForegroundColor Cyan
    firebase projects:list
}

# Summary
Write-Host "`n📋 Deployment Validation Summary:" -ForegroundColor Cyan
Write-Host "------------------------------" -ForegroundColor Cyan

if ($flutter_ok -and $firebase_ok -and $android_config -and $firebase_json) {
    Write-Host "✅ Core deployment prerequisites met" -ForegroundColor Green
} else {
    Write-Host "❌ Some deployment prerequisites missing" -ForegroundColor Red
}

Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Configure GitHub secrets for workflows" -ForegroundColor White
Write-Host "2. Run Firebase deployment with: firebase deploy --only hosting" -ForegroundColor White
Write-Host "3. Verify the deployment in Firebase Console" -ForegroundColor White
Write-Host "4. Test the web deployment in a browser" -ForegroundColor White

Write-Host "`nValidation complete." -ForegroundColor Cyan
