# AstroYorumAI VM Service Optimized Test Runner
# Bu script VM service ayarlarını optimize ederek çökmeleri önler

param(
    [string]$TestPattern = "",
    [switch]$SingleFile,
    [switch]$Verbose
)

Write-Host "AstroYorumAI VM Service Optimized Test Runner" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# VM service optimization parametreleri
$env:FLUTTER_TEST_ARGS = "--dart-define=flutter.test.timeout=120000"
$env:DART_VM_OPTIONS = "--old-gen-heap-size=4096 --new-gen-heap-size=512"

# Flutter test optimization flags
$TEST_FLAGS = @(
    "--coverage"
    "--timeout=120s"
    "--concurrency=1"  # Tek seferde bir test çalıştır
    "--reporter=compact"
)

if ($Verbose) {
    $TEST_FLAGS += "--verbose"
}

Write-Host "VM Options: $env:DART_VM_OPTIONS" -ForegroundColor Yellow
Write-Host "Test Flags: $($TEST_FLAGS -join ' ')" -ForegroundColor Yellow

function Invoke-SafeFlutterTest {
    param(
        [string[]]$TestFiles,
        [string]$BatchName = "test"
    )
    
    Write-Host "`nRunning $BatchName..." -ForegroundColor Green
    
    try {
        Write-Host "[CLEANUP] Pre-test cleanup..." -ForegroundColor Gray
        flutter clean | Out-Null
        Write-Host "[GC] Forcing garbage collection..." -ForegroundColor Gray
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        [System.GC]::Collect()
        Write-Host "[DEPS] Refreshing dependencies..." -ForegroundColor Gray
        flutter pub get | Out-Null
        $testArgs = $TEST_FLAGS + $TestFiles
        $cmd = "flutter test " + ($testArgs -join " ")
        Write-Host "[CMD] Command: $cmd" -ForegroundColor Yellow
        $process = Start-Process -FilePath "flutter" -ArgumentList ("test " + ($testArgs -join " ")) -NoNewWindow -PassThru -Wait
        
        if ($process.ExitCode -eq 0) {
            Write-Host "[SUCCESS] $BatchName completed successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[FAIL] $BatchName failed with exit code: $($process.ExitCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "[FAIL] $BatchName failed with exception: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        Write-Host "[CLEANUP] Post-test cleanup..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
    }
}

# Özel test modları
if ($SingleFile -and $TestPattern) {
    Write-Host "[MODE] Single file mode: $TestPattern" -ForegroundColor Magenta
    $result = Invoke-SafeFlutterTest -TestFiles @($TestPattern) -BatchName "Single File Test"
    
    if ($result -and (Test-Path "coverage/lcov.info")) {
        Write-Host "[COVERAGE] Coverage generated successfully" -ForegroundColor Green
        $coverageSize = (Get-Item "coverage/lcov.info").Length
        Write-Host "[SIZE] Coverage file size: $coverageSize bytes" -ForegroundColor Cyan
    }
    
    exit
}

# Test dosyalarını topla
Write-Host "[FILES] Collecting test files..." -ForegroundColor Cyan
$allTestFiles = Get-ChildItem -Path "test" -Recurse -Name "*.dart" | Where-Object { 
    $_ -notmatch "integration" -and $_ -notmatch ".mocks.dart" 
}

if ($TestPattern) {
    $allTestFiles = $allTestFiles | Where-Object { $_ -match $TestPattern }
}

Write-Host "[INFO] Found $($allTestFiles.Count) test files" -ForegroundColor Green

# Service test dosyalarını ayrı kategoriler halinde test et
$serviceTests = $allTestFiles | Where-Object { $_.FullName -match "services" }
$screenTests = $allTestFiles | Where-Object { $_.FullName -match "screens" }
$otherTests = $allTestFiles | Where-Object { $_.FullName -notmatch "services" -and $_.FullName -notmatch "screens" }

Write-Host "`n[CATEGORIES] Test Categories:" -ForegroundColor Cyan
Write-Host "   [SERVICE] Service tests: $($serviceTests.Count)" -ForegroundColor Yellow
Write-Host "   [SCREEN] Screen tests: $($screenTests.Count)" -ForegroundColor Yellow  
Write-Host "   [OTHER] Other tests: $($otherTests.Count)" -ForegroundColor Yellow

$successCount = 0
$totalCategories = 0

# Service tests
if ($serviceTests.Count -gt 0) {
    $totalCategories++
    Write-Host "`n[TESTING] Testing Service Tests..." -ForegroundColor Magenta
    $testPaths = $serviceTests | ForEach-Object { $_.FullName }
    if (Invoke-SafeFlutterTest -TestFiles $testPaths -BatchName "Service Tests") {
        $successCount++
        if (Test-Path "coverage/lcov.info") {
            Copy-Item "coverage/lcov.info" "coverage/services_lcov.info" -Force
        }
    }
}

# Screen tests  
if ($screenTests.Count -gt 0) {
    $totalCategories++
    Write-Host "`n[TESTING] Testing Screen Tests..." -ForegroundColor Magenta
    $testPaths = $screenTests | ForEach-Object { $_.FullName }
    if (Invoke-SafeFlutterTest -TestFiles $testPaths -BatchName "Screen Tests") {
        $successCount++
        if (Test-Path "coverage/lcov.info") {
            Copy-Item "coverage/lcov.info" "coverage/screens_lcov.info" -Force
        }
    }
}

# Other tests
if ($otherTests.Count -gt 0) {
    $totalCategories++
    Write-Host "`n[TESTING] Testing Other Tests..." -ForegroundColor Magenta
    $testPaths = $otherTests | ForEach-Object { $_.FullName }
    if (Invoke-SafeFlutterTest -TestFiles $testPaths -BatchName "Other Tests") {
        $successCount++
        if (Test-Path "coverage/lcov.info") {
            Copy-Item "coverage/lcov.info" "coverage/others_lcov.info" -Force
        }
    }
}

# Sonuç raporu
Write-Host "`n[RESULTS] FINAL RESULTS" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host "[SUCCESS] Successful categories: $successCount" -ForegroundColor Green
Write-Host "[FAIL] Failed categories: $($totalCategories - $successCount)" -ForegroundColor Red
Write-Host "[INFO] Total categories: $totalCategories" -ForegroundColor Cyan

# Coverage dosyalarını birleştir
if ($successCount -gt 0) {
    Write-Host "`n[COMBINE] Combining coverage files..." -ForegroundColor Yellow
    
    $combinedContent = ""
    @("services", "screens", "others") | ForEach-Object {
        $coverageFile = "coverage/${_}_lcov.info"
        if (Test-Path $coverageFile) {
            Write-Host "   [ADD] Adding $_..." -ForegroundColor Gray
            $content = Get-Content $coverageFile -Raw
            $combinedContent += $content + "`n"
        }
    }
    
    if ($combinedContent.Length -gt 0) {
        $finalCoverage = "coverage/combined_optimized_lcov.info"
        Set-Content -Path $finalCoverage -Value $combinedContent
        Write-Host "[SUCCESS] Combined coverage saved to: $finalCoverage" -ForegroundColor Green
        
        # İstatistikler
        $lineCount = (Get-Content $finalCoverage | Measure-Object -Line).Lines
        Write-Host "[SIZE] Coverage lines: $lineCount" -ForegroundColor Cyan
    }
}

Write-Host "`n[COMPLETE] VM Service Optimized Test Run Completed!" -ForegroundColor Green
