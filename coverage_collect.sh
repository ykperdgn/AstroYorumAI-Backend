#!/usr/bin/env bash

# AstroYorumAI Memory-Optimized Coverage Collection
# Bu script VM service çökmelerini önlemek için memory-safe yaklaşım kullanır

set -e

echo "🚀 AstroYorumAI Memory-Optimized Coverage Collection"
echo "=================================="

BATCH_SIZE=${1:-2}
OUTPUT_DIR="coverage_batches"
FINAL_COVERAGE="coverage/final_lcov.info"

echo "📊 Batch size: $BATCH_SIZE tests per batch"

# Output directory oluştur
mkdir -p "$OUTPUT_DIR"
mkdir -p "coverage"

# Test dosyalarını topla (integration ve mock dosyaları hariç)
echo "📁 Collecting test files..."
TEST_FILES=($(find test -name "*.dart" -not -path "*/integration/*" -not -name "*.mocks.dart" | sort))

echo "✅ Found ${#TEST_FILES[@]} test files"

# Batch'lere böl
TOTAL_BATCHES=$(( (${#TEST_FILES[@]} + BATCH_SIZE - 1) / BATCH_SIZE ))
echo "📦 Will process $TOTAL_BATCHES batches"

SUCCESSFUL_BATCHES=0
FAILED_BATCHES=0

# Her batch'i işle
for ((i=0; i<${#TEST_FILES[@]}; i+=BATCH_SIZE)); do
    BATCH_NUM=$(( i/BATCH_SIZE + 1 ))
    
    echo ""
    echo "🔄 Processing Batch $BATCH_NUM/$TOTAL_BATCHES"
    echo "----------------------------------------"
    
    # Bu batch'teki dosyalar
    BATCH_FILES=()
    for ((j=i; j<i+BATCH_SIZE && j<${#TEST_FILES[@]}; j++)); do
        BATCH_FILES+=("${TEST_FILES[j]}")
        echo "   📝 ${TEST_FILES[j]}"
    done
    
    # Memory temizleme
    echo "🧹 Cleaning Flutter cache..."
    flutter clean > /dev/null 2>&1 || true
    
    # Memory gc zorla
    echo "🗑️  Forcing garbage collection..."
    if command -v dartaotruntime >/dev/null 2>&1; then
        dart --observe --disable-service-auth-codes --enable-vm-service=8181 -e "print('gc'); exit(0);" > /dev/null 2>&1 || true
    fi
    
    # Kısa bekleme
    sleep 1
    
    # Dependencies yenile
    echo "📦 Refreshing dependencies..."
    flutter pub get > /dev/null 2>&1
    
    # Coverage topla
    echo "🎯 Running coverage for batch $BATCH_NUM..."
    
    if timeout 120 flutter test --coverage "${BATCH_FILES[@]}" 2>/dev/null; then
        if [[ -f "coverage/lcov.info" && -s "coverage/lcov.info" ]]; then
            # Batch coverage'ını kaydet
            BATCH_COVERAGE="$OUTPUT_DIR/batch_${BATCH_NUM}.lcov"
            cp "coverage/lcov.info" "$BATCH_COVERAGE"
            echo "✅ Batch $BATCH_NUM completed successfully"
            ((SUCCESSFUL_BATCHES++))
        else
            echo "❌ Batch $BATCH_NUM failed - empty or missing coverage file"
            ((FAILED_BATCHES++))
        fi
    else
        echo "❌ Batch $BATCH_NUM failed - test execution error or timeout"
        ((FAILED_BATCHES++))
    fi
    
    # Memory temizleme aralığı
    echo "⏳ Waiting for VM cleanup..."
    sleep 3
    
    # Progress göster
    PROGRESS=$(( (BATCH_NUM * 100) / TOTAL_BATCHES ))
    echo "📈 Progress: $PROGRESS% ($BATCH_NUM/$TOTAL_BATCHES batches)"
done

echo ""
echo "📊 COVERAGE COLLECTION SUMMARY"
echo "=============================="
echo "✅ Successful batches: $SUCCESSFUL_BATCHES"
echo "❌ Failed batches: $FAILED_BATCHES"
echo "📦 Total batches: $TOTAL_BATCHES"

# Coverage dosyalarını birleştir
if [[ $SUCCESSFUL_BATCHES -gt 0 ]]; then
    echo ""
    echo "🔗 Combining coverage files..."
    
    # Eski combined dosyayı temizle
    rm -f "$FINAL_COVERAGE"
    
    # Tüm batch dosyalarını birleştir
    for ((i=1; i<=TOTAL_BATCHES; i++)); do
        BATCH_FILE="$OUTPUT_DIR/batch_${i}.lcov"
        if [[ -f "$BATCH_FILE" ]]; then
            echo "   📁 Adding batch $i..."
            cat "$BATCH_FILE" >> "$FINAL_COVERAGE"
            echo "" >> "$FINAL_COVERAGE"  # Separator ekle
        fi
    done
    
    if [[ -f "$FINAL_COVERAGE" ]]; then
        echo "✅ Combined coverage saved to: $FINAL_COVERAGE"
        
        # Coverage istatistikleri
        LINES_COVERED=$(grep -c "^DA:" "$FINAL_COVERAGE" 2>/dev/null || echo "0")
        echo "📈 Total coverage lines: $LINES_COVERED"
        
        # HTML raporu oluştur (eğer lcov yüklüyse)
        if command -v genhtml >/dev/null 2>&1; then
            echo "🌐 Generating HTML coverage report..."
            genhtml "$FINAL_COVERAGE" -o coverage/html --title "AstroYorumAI Coverage Report" --legend
            echo "✅ HTML report generated in coverage/html/"
            echo "🌍 Open coverage/html/index.html in your browser"
        else
            echo "💡 Install lcov package to generate HTML reports: sudo apt-get install lcov"
        fi
    else
        echo "❌ No combined coverage file created"
    fi
else
    echo "❌ No successful batches to combine"
fi

echo ""
echo "🎉 Coverage collection completed!"
echo "📁 Batch files saved in: $OUTPUT_DIR/"
echo "📊 Final coverage file: $FINAL_COVERAGE"
