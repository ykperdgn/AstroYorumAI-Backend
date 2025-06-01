# PowerShell script to check deployment status
Write-Host "Checking AstroYorumAI API Deployment Status" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

$productionUrl = "https://astroyorumai-api.onrender.com"

# Test Health Endpoint
Write-Host "`nTesting Health Endpoint..." -ForegroundColor Yellow
try {
    $healthUrl = $productionUrl + "/health"
    $response = Invoke-WebRequest -Uri $healthUrl -Method GET -TimeoutSec 30
    Write-Host "SUCCESS - Health Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Gray
}
catch {
    Write-Host "ERROR - Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Root Endpoint
Write-Host "`nTesting Root Endpoint..." -ForegroundColor Yellow
try {
    $rootUrl = $productionUrl + "/"
    $response = Invoke-WebRequest -Uri $rootUrl -Method GET -TimeoutSec 30
    Write-Host "SUCCESS - Root Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Gray
}
catch {
    Write-Host "ERROR - Root Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Natal Chart Endpoint
Write-Host "`nTesting Natal Chart Endpoint..." -ForegroundColor Yellow
try {
    $natalUrl = $productionUrl + "/natal"
    $body = @{
        date = "1990/06/15"
        time = "14:30"
        latitude = 41.0082
        longitude = 28.9784
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri $natalUrl -Method POST -Body $body -ContentType "application/json" -TimeoutSec 30
    Write-Host "SUCCESS - Natal Chart Status: $($response.StatusCode)" -ForegroundColor Green
    
    if ($response.Content.Length -lt 500) {
        Write-Host "Response: $($response.Content)" -ForegroundColor Gray
    } else {
        Write-Host "Response: Large response - first 200 chars" -ForegroundColor Gray
        Write-Host $response.Content.Substring(0, 200) -ForegroundColor Gray
    }
}
catch {
    Write-Host "ERROR - Natal Chart Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host "Deployment Check Complete" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Check Render.com dashboard: https://dashboard.render.com/" -ForegroundColor Cyan
Write-Host "2. GitHub repository: https://github.com/ykperdgn/AstroYorumAI-Backend" -ForegroundColor Cyan
Write-Host "3. Expected production URL: $productionUrl" -ForegroundColor Cyan
