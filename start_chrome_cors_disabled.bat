@echo off
REM Chrome'u CORS olmadan başlat - Flutter web testing için
REM Bu script geçici olarak CORS check'ini disable eder

echo.
echo 🌐 Chrome'u CORS disabled olarak başlatılıyor...
echo ⚠️  Bu sadece development testing için kullanılmalıdır!
echo.
echo Flutter Web Default Ports:
echo   - flutter run -d chrome      : http://localhost:8080
echo   - flutter run -d web-server  : http://localhost:8080
echo   - Production build           : Varies by hosting
echo.
echo 🔗 Tavsiye edilen URL: http://localhost:8082
echo.

REM Chrome'u CORS disabled ve test data directory ile başlat
start chrome.exe --disable-web-security --disable-features=VizDisplayCompositor --user-data-dir="C:\temp\chrome_dev_cors_astroyorumai" --allow-running-insecure-content --ignore-certificate-errors --ignore-ssl-errors --allow-insecure-localhost "http://localhost:8082"

echo ✅ Chrome başlatıldı!
echo 💡 Eğer uygulama farklı bir portta çalışıyorsa, URL'yi manuel olarak girin.
echo 🚀 Şimdi Flutter uygulamasında natal chart test edebilirsiniz.
echo.
echo 📋 Geliştirici Konsolu için F12'ye basın
echo 🛠️  Network tab'da CORS hatalarını takip edebilirsiniz
echo.
pause
