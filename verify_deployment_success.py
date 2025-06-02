#!/usr/bin/env python3
"""
Post-Deployment Verification Script
Run this AFTER manual deployment on Render.com
"""
import requests
import json

def main():
    print("🔍 AstroYorumAI API - Post-Deployment Verification")
    print("=" * 55)
    
    base_url = "https://astroyorumai-api.onrender.com"
    
    # Test 1: Version Check
    print("\n1️⃣ Checking API Version...")
    try:
        response = requests.get(f"{base_url}/", timeout=30)
        if response.status_code == 200:
            data = response.json()
            version = data.get("version", "unknown")
            print(f"📦 Version: {version}")
            if version == "2.1.2-stable":
                print("✅ SUCCESS: Enhanced version deployed!")
            else:
                print(f"❌ ISSUE: Expected v2.1.2-stable, got v{version}")
                return False
        else:
            print(f"❌ API Error: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Connection Error: {e}")
        return False
    
    # Test 2: Status Endpoint
    print("\n2️⃣ Testing Status Endpoint...")
    try:
        response = requests.get(f"{base_url}/status", timeout=30)
        if response.status_code == 200:
            print("✅ Status endpoint working!")
            data = response.json()
            print(f"🚀 Deployment Version: {data.get('deployment_version')}")
        else:
            print(f"❌ Status endpoint failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Status endpoint error: {e}")
        return False
    
    # Test 3: Enhanced Natal Chart
    print("\n3️⃣ Testing Enhanced Natal Chart...")
    try:
        test_data = {
            "date": "1990-06-15",
            "time": "14:30",
            "latitude": 41.0082,
            "longitude": 28.9784
        }
        response = requests.post(f"{base_url}/natal", json=test_data, timeout=30)
        if response.status_code == 200:
            data = response.json()
            if "planets" in data and "ascendant" in data:
                planets = data["planets"]
                ascendant = data["ascendant"]
                print(f"✅ Enhanced data structure confirmed!")
                print(f"🪐 Planets found: {len(planets)}")
                print(f"🌅 Ascendant: {ascendant}")
                
                # Show sample planet data
                if planets:
                    sample_planet = list(planets.keys())[0]
                    planet_data = planets[sample_planet]
                    print(f"🌟 Sample ({sample_planet}): {planet_data}")
            else:
                print("❌ Missing enhanced data structure")
                print(f"Response keys: {list(data.keys())}")
                return False
        else:
            print(f"❌ Natal endpoint failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Natal endpoint error: {e}")
        return False
    
    # Success!
    print("\n" + "=" * 55)
    print("🎉 DEPLOYMENT VERIFICATION: SUCCESS!")
    print("✅ Enhanced API (v2.1.2-stable) is fully operational")
    print("✅ All endpoints working correctly")
    print("✅ Enhanced natal chart data available")
    print("✅ Ready for Flutter app integration")
    
    print("\n🚀 NEXT STEPS:")
    print("1. Test Flutter app with production API")
    print("2. Set up Firebase production environment")  
    print("3. Create beta APK for testing")
    print("4. Begin beta user recruitment")
    print("5. Launch beta testing phase")
    print("=" * 55)
    
    return True

if __name__ == "__main__":
    success = main()
    if not success:
        print("\n💡 If verification failed:")
        print("- Wait 2-3 minutes for deployment to complete")
        print("- Check Render.com build logs for errors")
        print("- Try running this script again")
        print("- Contact support if issues persist")
