import requests
import json

def test_render_natal_endpoint():
    url = "https://astroyorumai-api.onrender.com/natal"
    payload = {
        "date": "1990-06-15",
        "time": "14:30", 
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    print("🧪 Testing Render.com Natal Endpoint...")
    print(f"URL: {url}")
    
    try:
        response = requests.post(url, json=payload, timeout=30)
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ SUCCESS: Render natal endpoint working!")
            data = response.json()
            print(f"🌟 Planets: {len(data.get('planets', {}))}")
            print(f"🔮 Ascendant: {data.get('ascendant', 'N/A')}")
            print(f"⚙️ Method: {data.get('calculation_method', 'N/A')}")
            return True
        else:
            print(f"❌ FAILED: {response.status_code}")
            print(f"Response: {response.text[:300]}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    test_render_natal_endpoint()
