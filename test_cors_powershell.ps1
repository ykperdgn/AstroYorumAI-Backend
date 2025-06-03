#!/usr/bin/env pwsh
# CORS Test Script for AstroYorumAI API
# Tests CORS headers after enhanced deployment

Write-Host "🧪 Testing AstroYorumAI API CORS Configuration" -ForegroundColor Cyan
Write-Host "API URL: https://astroyorumai-api.onrender.com" -ForegroundColor Yellow
Write-Host ""

# Test 1: Basic API Health Check
Write-Host "1️⃣ Testing API Health..." -ForegroundColor Green
try {
    $healthResponse = Invoke-WebRequest -Uri "https://astroyorumai-api.onrender.com/health" -Method GET
    Write-Host "✅ Health Check: $($healthResponse.StatusCode)" -ForegroundColor Green
    
    # Check for CORS headers
    $corsHeaders = @()
    if ($healthResponse.Headers.ContainsKey('Access-Control-Allow-Origin')) {
        $corsHeaders += "Access-Control-Allow-Origin: $($healthResponse.Headers['Access-Control-Allow-Origin'])"
    }
    if ($healthResponse.Headers.ContainsKey('Access-Control-Allow-Methods')) {
        $corsHeaders += "Access-Control-Allow-Methods: $($healthResponse.Headers['Access-Control-Allow-Methods'])"
    }
    if ($healthResponse.Headers.ContainsKey('Access-Control-Allow-Headers')) {
        $corsHeaders += "Access-Control-Allow-Headers: $($healthResponse.Headers['Access-Control-Allow-Headers'])"
    }
    
    if ($corsHeaders.Count -gt 0) {
        Write-Host "✅ CORS Headers Found:" -ForegroundColor Green
        $corsHeaders | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    } else {
        Write-Host "⚠️ No CORS headers detected in response" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: OPTIONS Preflight Request
Write-Host "2️⃣ Testing CORS Preflight (OPTIONS)..." -ForegroundColor Green
try {
    $optionsResponse = Invoke-WebRequest -Uri "https://astroyorumai-api.onrender.com/natal" -Method OPTIONS
    Write-Host "✅ OPTIONS Request: $($optionsResponse.StatusCode)" -ForegroundColor Green
    
    # Check CORS headers on OPTIONS
    if ($optionsResponse.Headers.ContainsKey('Access-Control-Allow-Origin')) {
        Write-Host "✅ CORS Preflight headers present" -ForegroundColor Green
    } else {
        Write-Host "⚠️ CORS Preflight headers missing" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ OPTIONS Request Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: POST Request to /natal endpoint
Write-Host "3️⃣ Testing Natal Chart POST..." -ForegroundColor Green
try {
    $postData = @{
        date = "1990-01-15"
        time = "14:30"
        latitude = 41.0082
        longitude = 28.9784
    } | ConvertTo-Json

    $postResponse = Invoke-WebRequest -Uri "https://astroyorumai-api.onrender.com/natal" -Method POST -Body $postData -ContentType "application/json"
    Write-Host "✅ POST Request: $($postResponse.StatusCode)" -ForegroundColor Green
    
    $responseData = $postResponse.Content | ConvertFrom-Json
    if ($responseData.planets) {
        Write-Host "✅ Natal chart data received with $($responseData.planets.Count) planets" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Unexpected response format" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ POST Request Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Version Check
Write-Host "4️⃣ Checking API Version..." -ForegroundColor Green
try {
    $versionResponse = Invoke-WebRequest -Uri "https://astroyorumai-api.onrender.com/" -Method GET
    $versionData = $versionResponse.Content | ConvertFrom-Json
    Write-Host "✅ API Version: $($versionData.version)" -ForegroundColor Green
    Write-Host "✅ Build Time: $($versionData.build_timestamp)" -ForegroundColor Green
} catch {
    Write-Host "❌ Version Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🏁 CORS Test Complete!" -ForegroundColor Cyan
Write-Host "If all tests passed, CORS should be working for Flutter web app." -ForegroundColor White
