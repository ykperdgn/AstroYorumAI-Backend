import requests
print("🚀 Testing API health...")
try:
    response = requests.get("https://astroyorumai-api.onrender.com/health", timeout=10)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        print("✅ API is healthy!")
    else:
        print("❌ API health check failed")
except Exception as e:
    print(f"❌ Error: {e}")
print("Test completed!")
