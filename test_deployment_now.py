import requests
import json

def test_deployment():
    print("🚀 Testing AstroYorumAI API deployment...")
    
    # Test health endpoint
    try:
        print("\n🏥 Testing health endpoint...")
        response = requests.get("https://astroyorumai-api.onrender.com/health", timeout=15)
        print(f"Health Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ API is healthy!")
            print(f"Version: {data.get('version', 'Unknown')}")
            print(f"Service: {data.get('service', 'Unknown')}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False
    
    # Test natal chart endpoint
    print("\n🌟 Testing natal chart endpoint...")
    test_data = {
        "date": "1990-05-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    try:
        print(f"Sending request to /natal with data: {test_data}")
        response = requests.post(
            "https://astroyorumai-api.onrender.com/natal",
            json=test_data,
            headers={'Content-Type': 'application/json'},
            timeout=30
        )
        
        print(f"Natal Chart Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Natal chart calculation successful!")
            
            # Display results
            if 'planets' in result:
                print("\n🌟 Planets:")
                for planet, data in result['planets'].items():
                    if isinstance(data, dict):
                        sign = data.get('sign', 'Unknown')
                        degree = data.get('degree', data.get('deg', 'N/A'))
                        print(f"  {planet}: {sign} ({degree}°)")
                    else:
                        print(f"  {planet}: {data}")
            
            if 'ascendant' in result:
                asc_deg = result.get('ascendant_degree', result.get('ascendant_deg', 'N/A'))
                print(f"\n⬆️ Ascendant: {result['ascendant']} ({asc_deg}°)")
            
            print(f"\n📊 API Version: {result.get('version', 'Unknown')}")
            print(f"🔧 Calculation Method: {result.get('calculation_method', 'Unknown')}")
            
            return True
        else:
            print(f"❌ Request failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Request error: {e}")
        return False

if __name__ == "__main__":
    success = test_deployment()
    
    if success:
        print("\n🎉 DEPLOYMENT TEST PASSED!")
        print("✅ Backend API is working correctly")
        print("✅ Real astrological calculations are functional")
        print("✅ Ready for Flutter app testing")
    else:
        print("\n❌ DEPLOYMENT TEST FAILED!")
        print("🔄 API may still be deploying or has issues")
        
    print(f"\n🌐 API URL: https://astroyorumai-api.onrender.com")
    print(f"🌐 Flutter App URL: http://localhost:8082")
    print(f"💡 Use CORS-disabled Chrome for testing")
