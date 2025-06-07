# 🧪 Manual CORS Testing Procedure

## 🎯 Test Objective
Verify that the Flutter web app can successfully access the production API when CORS restrictions are disabled.

## 📋 Step-by-Step Testing

### 1. **Verify Chrome CORS-Disabled Launch**
- ✅ Chrome should have launched with a warning about disabled security
- ✅ Navigate to: `http://localhost:8082`
- ✅ Flutter AstroYorumAI app should load

### 2. **Test Production API Connection**
- Navigate to user profile or natal chart section
- Enter test birth data:
  - **Date**: June 15, 1990
  - **Time**: 14:30
  - **Location**: Istanbul, Turkey (or any location)
- Click "Calculate Natal Chart" or similar button

### 3. **Expected Results** ✅
- **Success Indicators**:
  - No CORS errors in browser console (F12)
  - Natal chart data loads successfully
  - Planets and ascendant information displayed
  - No 404 or network errors

### 4. **Browser Console Check** (F12)
- Open Developer Tools (F12)
- Go to Console tab
- Look for:
  - ✅ **No CORS errors**
  - ✅ **API calls return 200 OK**
  - ✅ **JSON responses with planet data**

### 5. **Network Tab Verification**
- In Developer Tools, go to Network tab
- Filter by XHR/Fetch requests
- Look for:
  - ✅ `GET https://astroyorumai-api.onrender.com/health` → 200
  - ✅ `POST https://astroyorumai-api.onrender.com/natal` → 200

## 🔍 Troubleshooting

### If CORS Errors Still Appear:
1. **Verify Chrome Launch**: Ensure Chrome was started with our script
2. **Check User Data Directory**: Chrome should show warning about disabled security
3. **Clear Browser Cache**: Hard refresh (Ctrl+Shift+R)
4. **Restart Process**: Close all Chrome windows and run script again

### If API Calls Fail:
1. **Check Network Connection**: Verify internet connectivity
2. **Test API Directly**: Run `dart run cors_debug_test.dart`
3. **Check API Status**: Visit https://astroyorumai-api.onrender.com/health

## 📊 Success Confirmation

If you see natal chart data with:
- ✅ **Planet positions** (Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn)
- ✅ **Ascendant sign** (e.g., "Libra", "Virgo", etc.)
- ✅ **No error messages**
- ✅ **No CORS warnings in console**

**🎉 CONGRATULATIONS! CORS issue is resolved!**

## 📝 Next Steps After Success

1. **Production Deployment**: Deploy web app to eliminate CORS permanently
2. **Mobile Apps**: Build APK/iOS apps (no CORS restrictions)
3. **User Testing**: Share with beta testers
4. **Firebase Setup**: Complete user authentication

## 📞 Support

If issues persist:
1. Check `CORS_RESOLUTION_STATUS.md` for detailed status
2. Run comprehensive tests: `dart run cors_debug_test.dart`
3. Review console logs for specific error messages

---
**Testing URL**: http://localhost:8082
**Production API**: https://astroyorumai-api.onrender.com
**Status**: Ready for testing
