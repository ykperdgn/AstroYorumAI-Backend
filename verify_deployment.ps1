# AstroYorumAI Render.com Deployment Verification Script
# This script helps verify and troubleshoot the Render.com deployment

Write-Host "🚀 AstroYorumAI API Deployment Verification" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

$baseUrl = "https://astroyorumai-api.onrender.com"
$timeout = 30

function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Name,
        [string]$Method = "GET",
        [hashtable]$Body = $null
    )
    
    Write-Host "`n🔍 Testing $Name..." -ForegroundColor Yellow
    Write-Host "URL: $Url" -ForegroundColor Gray
    
    try {
        $splat = @{
            Uri = $Url
            Method = $Method
            TimeoutSec = $timeout
            ErrorAction = "Stop"
        }
        
        if ($Body) {
            $splat.Body = ($Body | ConvertTo-Json)
            $splat.ContentType = "application/json"
        }
        
        $response = Invoke-WebRequest @splat
        
        Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Response: $($response.Content)" -ForegroundColor Green
        return $true
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMessage = $_.Exception.Message
        
        if ($statusCode) {
            Write-Host "❌ Status: $statusCode" -ForegroundColor Red
        } else {
            Write-Host "❌ Connection Error" -ForegroundColor Red
        }
        Write-Host "Error: $errorMessage" -ForegroundColor Red
        return $false
    }
}

# Test different possible URLs
$testUrls = @(
    @{Url="$baseUrl"; Name="Root Endpoint"},
    @{Url="$baseUrl/"; Name="Root with Slash"},
    @{Url="$baseUrl/health"; Name="Health Check"},
    @{Url="https://astroyorumai-backend.onrender.com"; Name="Alternative URL 1"},
    @{Url="https://astroyorumai-backend.onrender.com/health"; Name="Alternative URL 1 Health"},
    @{Url="https://astroyorum-ai-backend.onrender.com"; Name="Alternative URL 2"},
    @{Url="https://astroyorum-ai-backend.onrender.com/health"; Name="Alternative URL 2 Health"}
)

$successCount = 0
foreach ($test in $testUrls) {
    if (Test-Endpoint -Url $test.Url -Name $test.Name) {
        $successCount++
    }
}

# Test POST endpoint if any GET endpoint worked
if ($successCount -gt 0) {
    Write-Host "`n🧪 Testing Natal Chart API..." -ForegroundColor Yellow
    $testData = @{
        date = "1990-01-01"
        time = "12:00"
        latitude = 41.0082
        longitude = 28.9784
    }
    
    Test-Endpoint -Url "$baseUrl/natal" -Name "Natal Chart API" -Method "POST" -Body $testData
}

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "🏁 Verification completed. Successful tests: $successCount" -ForegroundColor Green

if ($successCount -eq 0) {
    Write-Host "`n💡 Troubleshooting suggestions:" -ForegroundColor Cyan
    Write-Host "1. Check Render.com dashboard for deployment status" -ForegroundColor White
    Write-Host "2. Verify the service name matches the URL" -ForegroundColor White
    Write-Host "3. Check build logs for any errors" -ForegroundColor White
    Write-Host "4. Ensure the Procfile and requirements.txt are correct" -ForegroundColor White
    Write-Host "5. Wait a few more minutes for deployment to complete" -ForegroundColor White
}
