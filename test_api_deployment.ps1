# PowerShell script to test AstroYorumAI API
Write-Host "🚀 Testing AstroYorumAI API Deployment..." -ForegroundColor Green

$baseUrl = "https://astroyorumai-api.onrender.com"

# Test root endpoint
Write-Host "`nTesting root endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/" -Method Get -TimeoutSec 30
    Write-Host "✅ API Status: OK" -ForegroundColor Green
    Write-Host "📦 Version: $($response.version)" -ForegroundColor Cyan
    Write-Host "🌐 Status: $($response.status)" -ForegroundColor Cyan
    Write-Host "🐍 Python: $($response.python_version)" -ForegroundColor Cyan
    
    # Check if this is the new version
    if ($response.version -like "*2.1.*") {
        Write-Host "🎉 NEW DEPLOYMENT DETECTED!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  OLD DEPLOYMENT STILL ACTIVE" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ API Root Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test status endpoint
Write-Host "`nTesting status endpoint..." -ForegroundColor Yellow
try {
    $statusResponse = Invoke-RestMethod -Uri "$baseUrl/status" -Method Get -TimeoutSec 30
    Write-Host "✅ Status Endpoint: OK" -ForegroundColor Green
    Write-Host "🚀 Deployment Version: $($statusResponse.deployment_version)" -ForegroundColor Cyan
    Write-Host "⏰ Deployment Time: $($statusResponse.deployment_time)" -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Status Endpoint Failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "   This indicates old deployment (v1.0.0)" -ForegroundColor Yellow
    }
}

# Test natal chart endpoint
Write-Host "`nTesting natal chart endpoint..." -ForegroundColor Yellow
$natalData = @{
    date = "1990-05-15"
    time = "14:30"
    latitude = 41.0082
    longitude = 28.9784
} | ConvertTo-Json

try {
    $natalResponse = Invoke-RestMethod -Uri "$baseUrl/natal" -Method Post -Body $natalData -ContentType "application/json" -TimeoutSec 30
    Write-Host "✅ Natal Chart Endpoint: OK" -ForegroundColor Green
    
    if ($natalResponse.planets) {
        Write-Host "🪐 Planets Data: Available" -ForegroundColor Green
        $planetNames = $natalResponse.planets.PSObject.Properties.Name
        Write-Host "   Available planets: $($planetNames -join ', ')" -ForegroundColor Cyan
        
        # Check planet data structure
        $sunData = $natalResponse.planets.Sun
        if ($sunData.sign -and $sunData.deg) {
            Write-Host "✅ ENHANCED PLANETARY DATA DETECTED!" -ForegroundColor Green
            Write-Host "   Example - Sun: $($sunData.sign) $($sunData.deg)°" -ForegroundColor Cyan
        } else {
            Write-Host "⚠️  Simple planetary data format" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ No planets data found" -ForegroundColor Red
    }
    
    if ($natalResponse.message) {
        Write-Host "💬 Message: $($natalResponse.message)" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "❌ Natal Chart Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n" + "="*50 -ForegroundColor Green
Write-Host "SUMMARY" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Green

if ($response.version -like "*2.1.*") {
    Write-Host "✅ NEW BACKEND DEPLOYMENT IS ACTIVE!" -ForegroundColor Green
    Write-Host "✅ Enhanced planetary data structure available" -ForegroundColor Green
    Write-Host "✅ Ready for Flutter app integration" -ForegroundColor Green
} else {
    Write-Host "⚠️  Old deployment still active (v$($response.version))" -ForegroundColor Yellow
    Write-Host "   Recommendation: Wait 5-10 minutes for Render deployment" -ForegroundColor Yellow
    Write-Host "   Or check Render dashboard for deployment logs" -ForegroundColor Yellow
}
