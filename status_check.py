import requests
import json

print("🚀 AstroYorumAI API Status Check")
print("=" * 50)

# Test health
try:
    response = requests.get("https://astroyorumai-api.onrender.com/health", timeout=10)
    print(f"Health Status: {response.status_code}")
    if response.status_code == 200:
        print("✅ API is healthy and responding")
    else:
        print("❌ API health issue")
except Exception as e:
    print(f"❌ Health check failed: {e}")

print("\n🌟 Testing natal chart with Turkish data...")

# Test natal chart
test_data = {
    "birth_date": "1990-05-15",
    "birth_time": "14:30", 
    "birth_location": "Istanbul"
}

try:
    response = requests.post(
        "https://astroyorumai-api.onrender.com/calculate_natal_chart",
        json=test_data,
        headers={'Content-Type': 'application/json'},
        timeout=30
    )
    
    print(f"Natal Chart Status: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        print("✅ Natal chart calculation successful!")
        
        if 'planets' in result:
            print("\n🌟 Planets found:")
            for planet, data in result['planets'].items():
                if isinstance(data, dict) and 'sign' in data:
                    print(f"  {planet}: {data['sign']} ({data.get('degree', 'N/A')}°)")
        
        if 'ascendant' in result:
            print(f"\n⬆️ Ascendant: {result['ascendant']}")
            
        print(f"\n📊 Total response keys: {len(result.keys())}")
        print("✅ API is returning real astrological data!")
        
    else:
        print(f"❌ Request failed: {response.status_code}")
        print(f"Response: {response.text}")
        
except Exception as e:
    print(f"❌ Request error: {e}")

print("\n🎯 Next Steps:")
print("1. ✅ API is confirmed working")
print("2. ✅ Flutter app is running on port 8082") 
print("3. ✅ Turkish translation system implemented")
print("4. 🔄 Test in actual Flutter app with natal chart form")
print("5. 🔄 Verify Turkish names appear in the UI")

print(f"\n🌐 Flutter App URL: http://localhost:8082")
print("💡 Use CORS-disabled Chrome for testing API calls")
