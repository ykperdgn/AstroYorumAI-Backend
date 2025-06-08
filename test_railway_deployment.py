import requests
import time
import json

def test_railway_deployment():
    """Test Railway deployment status and API functionality"""
    
    base_url = "https://astroyorumai-backend-production.up.railway.app"
    
    print("🚂 Testing Railway Deployment Status...")
    print(f"🔗 Base URL: {base_url}")
    print("=" * 60)
    
    # Test endpoints
    endpoints = [
        ("/health", "GET"),
        ("/", "GET"),
        ("/status", "GET"),
        ("/test", "GET")
    ]
    
    for endpoint, method in endpoints:
        url = base_url + endpoint
        try:
            print(f"\n📡 Testing {method} {endpoint}")
            
            if method == "GET":
                response = requests.get(url, timeout=30)
            else:
                response = requests.post(url, timeout=30)
            
            print(f"✅ Status: {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    print(f"📊 Response: {json.dumps(data, indent=2)}")
                except:
                    print(f"📄 Response: {response.text}")
            else:
                print(f"❌ Error: {response.text}")
                
        except requests.exceptions.Timeout:
            print(f"⏱️ Timeout - Service may be starting up")
        except requests.exceptions.ConnectionError:
            print(f"🔌 Connection Error - Service not available yet")
        except Exception as e:
            print(f"❌ Error: {str(e)}")
    
    # Test natal chart endpoint
    print(f"\n📡 Testing POST /natal")
    natal_data = {
        "date": "1990-06-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    try:
        url = base_url + "/natal"
        response = requests.post(url, json=natal_data, timeout=30)
        print(f"✅ Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"📊 Natal Chart Response:")
            print(f"   - Planets: {len(data.get('planets', {}))}")
            print(f"   - Ascendant: {data.get('ascendant', 'N/A')}")
            print(f"   - Method: {data.get('calculation_method', 'N/A')}")
            print(f"   - Version: {data.get('version', 'N/A')}")
        else:
            print(f"❌ Error: {response.text}")
            
    except Exception as e:
        print(f"❌ Natal Test Error: {str(e)}")
    
    print("\n" + "=" * 60)
    print("🎯 Railway Deployment Test Complete!")

if __name__ == "__main__":
    test_railway_deployment()
