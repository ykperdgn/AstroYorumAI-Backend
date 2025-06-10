@echo off
REM Chrome'u CORS olmadan başlat - Flutter web testing için
REM Bu script geçici olarak CORS check'ini disable eder

echo 🌐 Chrome'u CORS disabled olarak başlatılıyor...
echo ⚠️  Bu sadece development testing için kullanılmalıdır!
echo.
echo Flutter App URL: http://localhost:8082
echo.

REM Chrome'u CORS disabled ve test data directory ile başlat
start chrome.exe --disable-web-security --disable-features=VizDisplayCompositor --user-data-dir="C:\temp\chrome_dev_cors" --allow-running-insecure-content http://localhost:8082

echo ✅ Chrome başlatıldı!
echo 💡 Şimdi Flutter uygulamasında natal chart test edebilirsiniz.
echo.
pause
