import requests
import json
from datetime import datetime

def test_railway_deployment():
    """Test Railway deployment with comprehensive endpoint testing"""
    
    base_url = "https://astroyorumai-backend-production.up.railway.app"
    
    print("🚂 RAILWAY DEPLOYMENT TEST")
    print("=" * 50)
    print(f"Base URL: {base_url}")
    print(f"Test Time: {datetime.now()}")
    print()
    
    # Test 1: Health Check
    print("1. 🏥 Health Check...")
    try:
        response = requests.get(f"{base_url}/health", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Status: {data.get('status')}")
            print(f"   📋 Version: {data.get('version')}")
            print(f"   ⚙️  Method: {data.get('calculation_method')}")
            print(f"   🐍 Python: {data.get('python_version')}")
        else:
            print(f"   ❌ Failed: HTTP {response.status_code}")
            return False
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return False
    
    # Test 2: Natal Chart (Critical)
    print("\n2. 🌟 Natal Chart Calculation...")
    natal_data = {
        "date": "1990-06-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    try:
        response = requests.post(
            f"{base_url}/natal",
            json=natal_data,
            headers={"Content-Type": "application/json"},
            timeout=15
        )
        
        if response.status_code == 200:
            data = response.json()
            planets = data.get('planets', {})
            print(f"   ✅ Calculation successful")
            print(f"   🌞 Sun: {planets.get('Sun', 'N/A')}")
            print(f"   🌙 Moon: {planets.get('Moon', 'N/A')}")
            print(f"   ♎ Ascendant: {data.get('ascendant', 'N/A')}")
            print(f"   🔄 Method: {data.get('calculation_method', 'N/A')}")
        else:
            print(f"   ❌ Failed: HTTP {response.status_code}")
            print(f"   📄 Response: {response.text}")
            return False
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return False
    
    # Test 3: CORS Check
    print("\n3. 🌐 CORS Configuration...")
    try:
        response = requests.options(f"{base_url}/natal", timeout=10)
        cors_headers = {
            'Access-Control-Allow-Origin': response.headers.get('Access-Control-Allow-Origin'),
            'Access-Control-Allow-Methods': response.headers.get('Access-Control-Allow-Methods'),
            'Access-Control-Allow-Headers': response.headers.get('Access-Control-Allow-Headers')
        }
        
        if cors_headers['Access-Control-Allow-Origin']:
            print(f"   ✅ CORS configured")
            print(f"   🌍 Origin: {cors_headers['Access-Control-Allow-Origin']}")
            print(f"   📝 Methods: {cors_headers['Access-Control-Allow-Methods']}")
        else:
            print("   ⚠️  CORS headers not found")
    except Exception as e:
        print(f"   ❌ CORS test error: {e}")
    
    # Test 4: Repository Connection Status
    print("\n4. 📁 Repository Connection...")
    try:
        # Check if the deployment includes latest changes
        response = requests.get(f"{base_url}/health", timeout=10)
        data = response.json()
        version = data.get('version', 'unknown')
        method = data.get('calculation_method', 'unknown')
        
        if 'skyfield' in method.lower() or 'railway' in version:
            print("   ✅ Latest code detected")
            print(f"   🔄 Version: {version}")
            print(f"   ⚙️  Method: {method}")
        else:
            print("   ⚠️  Old code version detected")
            print(f"   🔄 Version: {version}")
            print(f"   ⚙️  Method: {method}")
            print("   📋 Suggests GitHub repo not connected properly")
    except Exception as e:
        print(f"   ❌ Error checking version: {e}")
    
    print("\n" + "=" * 50)
    print("🎯 NEXT ACTIONS:")
    
    # Check if we have the repo connection issue
    try:
        response = requests.get(f"{base_url}/health", timeout=10)
        data = response.json()
        method = data.get('calculation_method', '')
        
        if 'flatlib' in method.lower() or 'swiss' in method.lower():
            print("❌ OLD CODE DEPLOYED - Repository connection issue detected!")
            print("🔧 REQUIRED ACTIONS:")
            print("   1. Go to Railway Dashboard")
            print("   2. Disconnect GitHub repository")
            print("   3. Reconnect GitHub repository")
            print("   4. Redeploy with latest skyfield code")
            return False
        else:
            print("✅ LATEST CODE DEPLOYED - Repository connection working!")
            return True
    except:
        print("⚠️  Could not determine code version")
        return False

if __name__ == "__main__":
    success = test_railway_deployment()
    exit(0 if success else 1)
