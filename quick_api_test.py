import requests
import json

# Test AstroYorumAI API
url = "https://astroyorumai-api.onrender.com/natal"
data = {
    "date": "1990-01-15",
    "time": "14:30", 
    "latitude": 41.0082,
    "longitude": 28.9784
}

print("🧪 Testing AstroYorumAI API...")
print(f"URL: {url}")
print(f"Data: {data}")

try:
    response = requests.post(url, json=data, headers={'Content-Type': 'application/json'})
    print(f"✅ Status: {response.status_code}")
    print(f"📥 Headers: {dict(response.headers)}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Success! Got {len(result.get('planets', []))} planets")
        print(f"🌟 Planets: {list(result.get('planets', {}).keys())}")
    else:
        print(f"❌ Error: {response.text}")
        
except Exception as e:
    print(f"🚨 Error: {e}")
