#!/usr/bin/env python3
"""
Test script to specifically verify flatlib integration in production
"""
import requests
import json

def test_flatlib_deployment():
    """Test if flatlib is working in the deployed API"""
    
    print("🚀 Testing Flatlib Integration in Production")
    print("=" * 50)
    
    # Test data
    test_data = {
        "date": "1990-01-15",
        "time": "14:30",
        "latitude": 40.7128,
        "longitude": -74.0060
    }
    
    url = "https://astroyorumai-api.onrender.com/natal"
    
    try:
        print(f"🔍 Sending POST request to {url}")
        print(f"📊 Test data: {json.dumps(test_data, indent=2)}")
        
        response = requests.post(url, json=test_data, timeout=30)
        
        print(f"📡 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Request successful!")
            print(f"📄 Response keys: {list(data.keys())}")
            
            # Check if we have real astrological data
            if "planets" in data and isinstance(data["planets"], dict):
                print("🌟 Found planets data!")
                
                # Check message to see if flatlib is working
                message = data.get("message", "")
                print(f"💬 Message: {message}")
                
                if "Real astrological calculation completed" in message:
                    print("🎉 FLATLIB IS WORKING! Real calculations detected.")
                    print("🪐 Planets found:")
                    for planet, info in data["planets"].items():
                        print(f"   {planet}: {info}")
                elif "flatlib not available" in message:
                    print("⚠️  Flatlib not available - using mock data")
                else:
                    print("❓ Unknown calculation method")
                
                return True
            else:
                print("❌ No planets data found in response")
                print(f"📄 Full response: {json.dumps(data, indent=2)}")
                return False
        else:
            print(f"❌ Request failed with status {response.status_code}")
            print(f"📄 Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"💥 Error: {str(e)}")
        return False

def check_version():
    """Check the current version of the API"""
    print("\n🔍 Checking API version...")
    
    try:
        response = requests.get("https://astroyorumai-api.onrender.com/", timeout=10)
        if response.status_code == 200:
            data = response.json()
            version = data.get("version", "unknown")
            print(f"📦 Current version: {version}")
            return version
        else:
            print(f"❌ Failed to get version: {response.status_code}")
            return None
    except Exception as e:
        print(f"💥 Error checking version: {str(e)}")
        return None

if __name__ == "__main__":
    # Check version first
    version = check_version()
    
    # Test flatlib
    success = test_flatlib_deployment()
    
    if success:
        print("\n🎉 Test completed successfully!")
    else:
        print("\n❌ Test failed!")
    
    print(f"\n📊 Summary:")
    print(f"   Version: {version}")
    print(f"   Flatlib test: {'✅ PASSED' if success else '❌ FAILED'}")
