#!/usr/bin/env python3
"""
Force deployment check and trigger script for AstroYorumAI API
This script helps identify why Render.com is not deploying the latest version
"""
import requests
import json
import time
from datetime import datetime

def check_current_deployment():
    """Check what version is currently deployed"""
    print("🔍 Checking current deployment...")
    
    base_url = "https://astroyorumai-api.onrender.com"
    
    # Test root endpoint
    try:
        response = requests.get(f"{base_url}/", timeout=30)
        if response.status_code == 200:
            data = response.json()
            current_version = data.get("version", "unknown")
            print(f"📦 Current deployed version: {current_version}")
            
            if current_version == "2.1.2-stable":
                print("✅ SUCCESS: Enhanced version is deployed!")
                return True
            else:
                print(f"❌ PROBLEM: Expected v2.1.2-stable, got v{current_version}")
                return False
        else:
            print(f"❌ Root endpoint failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"💥 Error checking deployment: {e}")
        return False

def check_status_endpoint():
    """Check if the new /status endpoint exists"""
    print("\n🔍 Checking /status endpoint (only exists in v2.1.2-stable)...")
    
    try:
        response = requests.get("https://astroyorumai-api.onrender.com/status", timeout=30)
        if response.status_code == 200:
            data = response.json()
            print("✅ /status endpoint found!")
            print(f"📦 Deployment version: {data.get('deployment_version')}")
            print(f"⏰ Deployment time: {data.get('deployment_time')}")
            return True
        elif response.status_code == 404:
            print("❌ /status endpoint not found (old version still deployed)")
            return False
        else:
            print(f"❌ /status endpoint error: {response.status_code}")
            return False
    except Exception as e:
        print(f"💥 Error checking /status: {e}")
        return False

def test_enhanced_natal():
    """Test if natal endpoint returns enhanced data structure"""
    print("\n🔍 Testing natal endpoint for enhanced data...")
    
    test_data = {
        "date": "1990-06-15",
        "time": "14:30", 
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    try:
        response = requests.post("https://astroyorumai-api.onrender.com/natal", 
                               json=test_data, timeout=30)
        if response.status_code == 200:
            data = response.json()
            
            # Check for enhanced structure
            if "planets" in data and "ascendant" in data:
                print("✅ Enhanced natal data structure found!")
                planets = data.get("planets", {})
                print(f"🪐 Planets found: {len(planets)}")
                if planets:
                    sample_planet = list(planets.keys())[0]
                    planet_data = planets[sample_planet]
                    print(f"🌟 Sample ({sample_planet}): sign={planet_data.get('sign')}, deg={planet_data.get('deg')}")
                print(f"🌅 Ascendant: {data.get('ascendant')}")
                return True
            else:
                print("❌ Old natal data structure (missing planets/ascendant)")
                print(f"📝 Response keys: {list(data.keys())}")
                return False
        else:
            print(f"❌ Natal endpoint failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"💥 Error testing natal endpoint: {e}")
        return False

def main():
    """Main deployment verification"""
    print("🚀 AstroYorumAI Deployment Verification")
    print("=" * 60)
    print(f"⏰ Check time: {datetime.now().isoformat()}")
    print("=" * 60)
    
    # Run all checks
    checks = [
        ("Current Version", check_current_deployment),
        ("Status Endpoint", check_status_endpoint),
        ("Enhanced Natal Data", test_enhanced_natal)
    ]
    
    passed = 0
    total = len(checks)
    
    for check_name, check_func in checks:
        print(f"\n📋 {check_name}:")
        if check_func():
            passed += 1
        time.sleep(1)  # Brief pause between checks
    
    print("\n" + "=" * 60)
    print(f"🎯 VERIFICATION SUMMARY: {passed}/{total} checks passed")
    
    if passed == total:
        print("🎉 SUCCESS: Enhanced API (v2.1.2-stable) is fully deployed!")
        print("✅ Ready for Flutter app integration and beta testing")
    elif passed > 0:
        print("⚠️  PARTIAL: Some features working, deployment may be in progress")
        print("💡 Wait 5-10 minutes and run this script again")
    else:
        print("❌ FAILED: Old version still deployed")
        print("💡 Manual intervention needed on Render.com dashboard")
        
    print("\n📱 Next Steps:")
    if passed == total:
        print("1. Update Flutter app to use production API")
        print("2. Test Flutter app end-to-end")
        print("3. Set up Firebase production environment")
        print("4. Begin beta testing recruitment")
    else:
        print("1. Check Render.com dashboard for deployment status")
        print("2. Trigger manual deployment if needed")
        print("3. Check build logs for any errors")
        print("4. Run this script again in 10 minutes")
    
    print("=" * 60)

if __name__ == "__main__":
    main()
