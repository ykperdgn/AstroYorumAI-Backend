import requests
import json
import sys

def test_natal_endpoint():
    url = "http://localhost:5000/natal"
    payload = {
        "date": "1990-06-15", 
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    headers = {
        'Content-Type': 'application/json'
    }
    
    print("🧪 Testing Local Natal Endpoint...")
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(payload, indent=2)}")
    
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=30)
        
        print(f"\n📊 Response Status: {response.status_code}")
        print(f"📊 Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            print("✅ SUCCESS: Natal endpoint working!")
            try:
                data = response.json()
                print(f"🌟 Planets found: {len(data.get('planets', {}))}")
                print(f"🔮 Ascendant: {data.get('ascendant', 'N/A')}")
                print(f"⚙️ Calculation Method: {data.get('calculation_method', 'N/A')}")
                return True
            except json.JSONDecodeError:
                print(f"❌ Invalid JSON response: {response.text[:200]}")
                return False
        else:
            print(f"❌ FAILED: Status {response.status_code}")
            print(f"❌ Response: {response.text[:500]}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request Error: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected Error: {e}")
        return False

if __name__ == "__main__":
    success = test_natal_endpoint()
    sys.exit(0 if success else 1)
