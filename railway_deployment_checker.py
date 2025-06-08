import requests
import json
import time

def check_railway_deployment():
    """Check if Railway deployment is complete and working"""
    url = "https://astroyorumai-backend-production.up.railway.app/health"
    
    print("🚂 CHECKING RAILWAY DEPLOYMENT STATUS")
    print("=" * 50)
    
    for attempt in range(3):
        try:
            print(f"Attempt {attempt + 1}/3...")
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                print(f"✅ API Status: {data.get('status')}")
                print(f"📋 Version: {data.get('version')}")
                print(f"⚙️  Method: {data.get('calculation_method')}")
                print(f"🐍 Python: {data.get('python_version')}")
                print(f"🌐 Platform: {data.get('platform', 'N/A')}")
                
                # Check if we have the new skyfield implementation
                method = data.get('calculation_method', '').lower()
                if 'skyfield' in method:
                    print("\n🎉 SUCCESS: New Skyfield code is deployed!")
                    return True
                elif 'flatlib' in method or 'swiss' in method:
                    print("\n⚠️  WARNING: Old flatlib code still running")
                    print("GitHub repository connection issue detected")
                    return False
                else:
                    print(f"\n❓ UNKNOWN: Unexpected calculation method: {data.get('calculation_method')}")
                    return False
                    
            else:
                print(f"❌ HTTP Error: {response.status_code}")
                print(f"Response: {response.text[:200]}")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Connection Error: {e}")
            
        if attempt < 2:
            print("Waiting 5 seconds before retry...")
            time.sleep(5)
    
    print("\n❌ FAILED: Could not connect to Railway API after 3 attempts")
    return False

def test_natal_endpoint():
    """Test the critical natal endpoint"""
    url = "https://astroyorumai-backend-production.up.railway.app/natal"
    
    test_data = {
        "date": "1990-06-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    print("\n🌟 TESTING NATAL ENDPOINT")
    print("=" * 30)
    
    try:
        response = requests.post(
            url, 
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=15
        )
        
        if response.status_code == 200:
            data = response.json()
            planets = data.get('planets', {})
            
            print("✅ Natal calculation successful!")
            print(f"🌞 Sun: {planets.get('Sun', 'N/A')}")
            print(f"🌙 Moon: {planets.get('Moon', 'N/A')}")
            print(f"♎ Ascendant: {data.get('ascendant', 'N/A')}")
            print(f"🔄 Method: {data.get('calculation_method', 'N/A')}")
            return True
        else:
            print(f"❌ Failed: HTTP {response.status_code}")
            print(f"Error: {response.text[:300]}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    # Check basic API health
    api_working = check_railway_deployment()
    
    # If API is working, test natal endpoint
    if api_working:
        natal_working = test_natal_endpoint()
        
        if natal_working:
            print("\n🎉 DEPLOYMENT SUCCESS!")
            print("✅ API is working")
            print("✅ Natal calculations working")
        else:
            print("\n⚠️  PARTIAL SUCCESS")
            print("✅ API is responding")
            print("❌ Natal endpoint has issues")
    else:
        print("\n❌ DEPLOYMENT FAILED")
        print("❌ API not responding correctly")
        
    print("\n" + "=" * 50)
    print("📋 NEXT STEPS:")
    print("1. Fix GitHub repository connection if needed")
    print("2. Complete skyfield migration if old code detected")
    print("3. Test all endpoints comprehensively")
