import requests
import json

# Test natal endpoint locally
url = "http://localhost:5000/natal"
payload = {
    "date": "1990-06-15",
    "time": "14:30",
    "latitude": 41.0082,
    "longitude": 28.9784
}

try:
    print("🧪 Testing local natal endpoint...")
    response = requests.post(url, json=payload)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
    
    if response.status_code == 200:
        print("✅ Local natal endpoint working!")
        data = response.json()
        print(f"Planets found: {len(data.get('planets', {}))}")
    else:
        print("❌ Local natal endpoint failed")
        
except Exception as e:
    print(f"❌ Error: {e}")
