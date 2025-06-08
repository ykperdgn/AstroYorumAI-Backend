@echo off
echo 🎯 Phase 2: Railway Backend Integration Test
echo ======================================================
echo.

set RAILWAY_URL=https://astroyorumai-backend-production.up.railway.app

echo 1️⃣ Testing Railway Backend Health Endpoint...
curl -s -w "Status: %%{http_code}\nTime: %%{time_total}s\n" "%RAILWAY_URL%/health"
echo.
echo.

echo 2️⃣ Testing Natal Chart API with Sample Data...
echo Sending POST request to %RAILWAY_URL%/natal
curl -s -X POST "%RAILWAY_URL%/natal" ^
  -H "Content-Type: application/json" ^
  -H "Accept: application/json" ^
  -d "{\"date\":\"1990-01-01\",\"time\":\"12:00\",\"latitude\":41.0082,\"longitude\":28.9784}" ^
  -w "\nStatus: %%{http_code}\nTime: %%{time_total}s\n"
echo.
echo.

echo 3️⃣ Testing CORS Configuration...
echo Sending OPTIONS request for CORS preflight
curl -s -X OPTIONS "%RAILWAY_URL%/natal" ^
  -H "Origin: http://localhost:3000" ^
  -H "Access-Control-Request-Method: POST" ^
  -H "Access-Control-Request-Headers: Content-Type" ^
  -w "Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.
echo.

echo ======================================================
echo ✅ Railway Backend Integration Test Complete!
echo 📱 Next: Test Flutter web app at http://localhost:3000
echo 🚀 Backend URL: %RAILWAY_URL%
echo ======================================================
