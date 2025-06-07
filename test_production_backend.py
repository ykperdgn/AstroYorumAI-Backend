#!/usr/bin/env python3
import requests
import json
import sys

def test_production_natal():
    """Test production natal endpoint"""
    url = "https://astroyorumai-api.onrender.com/natal"
    
    payload = {
        "date": "1990-06-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    print("🧪 Testing Production Natal Endpoint...")
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(payload, indent=2)}")
    
    try:
        response = requests.post(url, json=payload, timeout=30)
        
        print(f"\n📊 Response Status: {response.status_code}")
        print(f"⏱️ Response Time: {response.elapsed.total_seconds():.2f} seconds")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ SUCCESS! Production natal endpoint is working!")
            print(f"🌟 Calculated {len(data.get('planets', []))} planets")
            print(f"🏠 Calculated {len(data.get('houses', []))} houses")
            print(f"⭐ Calculated {len(data.get('aspects', []))} aspects")
            
            # Show first planet as example
            if data.get('planets'):
                first_planet = data['planets'][0]
                print(f"📍 Example - {first_planet['name']}: {first_planet['degree']:.2f}° in {first_planet['sign']}")
            
            return True
        else:
            print(f"❌ ERROR: Status {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Request Error: {e}")
        return False

def test_production_health():
    """Test production health endpoint"""
    url = "https://astroyorumai-api.onrender.com/health"
    
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health OK - {data.get('status', 'unknown')}")
            print(f"🔧 Version: {data.get('version', 'unknown')}")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Testing Production Backend...")
    
    # Test health first
    health_ok = test_production_health()
    print()
    
    # Test natal endpoint
    natal_ok = test_production_natal()
    
    print("\n" + "="*50)
    if health_ok and natal_ok:
        print("🎉 ALL TESTS PASSED! Production is working perfectly!")
        sys.exit(0)
    else:
        print("❌ Some tests failed. Check the output above.")
        sys.exit(1)
