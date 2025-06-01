# AstroYorumAI Coverage Collection Script
# Bu script VM service çökmelerini önlemek için batch'ler halinde coverage toplar

param(
    [int]$BatchSize = 3,
    [string]$OutputDir = "coverage_batches"
)

Write-Host "AstroYorumAI Coverage Collection Script" -ForegroundColor Green
Write-Host "Batch Size: $BatchSize" -ForegroundColor Yellow

# Coverage output dizinini oluştur
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force
    Write-Host "Created output directory: $OutputDir" -ForegroundColor Yellow
}

# Test dosyalarını al (integration testleri hariç)
$testFiles = Get-ChildItem -Path "test" -Recurse -Name "*.dart" | Where-Object { 
    $_ -notmatch "integration" -and $_ -notmatch ".mocks.dart" 
}

Write-Host "Found $($testFiles.Count) test files to process" -ForegroundColor Cyan

# Batch'lere böl
$batches = @()
for ($i = 0; $i -lt $testFiles.Count; $i += $BatchSize) {
    $batch = $testFiles[$i..([Math]::Min($i + $BatchSize - 1, $testFiles.Count - 1))]
    $batches += , $batch
}

Write-Host "Split into $($batches.Count) batches" -ForegroundColor Cyan

# Her batch için coverage topla
$successfulBatches = 0
$failedBatches = 0

for ($i = 0; $i -lt $batches.Count; $i++) {
    $batchNum = $i + 1
    $batch = $batches[$i]
    
    Write-Host "`nProcessing Batch $batchNum/$($batches.Count)..." -ForegroundColor Magenta
    Write-Host "Files in this batch:" -ForegroundColor Gray
    $batch | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    
    # Bu batch için test dosyalarını birleştir
    $testPaths = $batch | ForEach-Object { "test/$_" }
    $testArgs = $testPaths -join " "
    
    try {
        # Flutter clean (memory temizleme için)
        flutter clean | Out-Null
        flutter pub get | Out-Null
        
        # Coverage topla
        $cmd = "flutter test --coverage $testArgs"
        Write-Host "Running: $cmd" -ForegroundColor Yellow
        
        Invoke-Expression $cmd
        
        if (Test-Path "coverage/lcov.info") {
            $batchCoverageFile = "$OutputDir/batch_$batchNum.lcov"
            Copy-Item "coverage/lcov.info" $batchCoverageFile -Force
            Write-Host "✓ Batch $batchNum completed successfully" -ForegroundColor Green
            $successfulBatches++
        } else {
            Write-Host "✗ Batch $batchNum failed - no coverage file generated" -ForegroundColor Red
            $failedBatches++
        }
    }
    catch {
        Write-Host "✗ Batch $batchNum failed with error: $($_.Exception.Message)" -ForegroundColor Red
        $failedBatches++
    }
    
    # Kısa bekleme (VM service'in toparlanması için)
    Start-Sleep -Seconds 2
}

Write-Host "`n=== Coverage Collection Summary ===" -ForegroundColor Green
Write-Host "Successful batches: $successfulBatches" -ForegroundColor Green
Write-Host "Failed batches: $failedBatches" -ForegroundColor Red
Write-Host "Total batches: $($batches.Count)" -ForegroundColor Cyan

# Batch coverage dosyalarını birleştir
if ($successfulBatches -gt 0) {
    Write-Host "`nCombining batch coverage files..." -ForegroundColor Yellow
    
    $combinedFile = "coverage/combined_lcov.info"
    if (Test-Path "coverage") {
        Remove-Item "coverage" -Recurse -Force
    }
    New-Item -ItemType Directory -Path "coverage" -Force
    
    # Tüm batch dosyalarını birleştir
    $allContent = ""
    for ($i = 1; $i -le $batches.Count; $i++) {
        $batchFile = "$OutputDir/batch_$i.lcov"
        if (Test-Path $batchFile) {
            $content = Get-Content $batchFile -Raw
            $allContent += $content + "`n"
        }
    }
    
    if ($allContent -ne "") {
        Set-Content -Path $combinedFile -Value $allContent
        Write-Host "✓ Combined coverage saved to: $combinedFile" -ForegroundColor Green
        
        # HTML raporu oluştur
        if (Get-Command "genhtml" -ErrorAction SilentlyContinue) {
            Write-Host "Generating HTML coverage report..." -ForegroundColor Yellow
            genhtml $combinedFile -o coverage/html
            Write-Host "✓ HTML report generated in coverage/html/" -ForegroundColor Green
        } else {
            Write-Host "Note: genhtml not found. Install lcov for HTML reports." -ForegroundColor Yellow
        }
    }
}

Write-Host "`nCoverage collection completed!" -ForegroundColor Green
