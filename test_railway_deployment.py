#!/usr/bin/env python3
"""
Railway Deployment Test Script
Tests Railway production deployment endpoints
"""

import requests
import json
import sys
import time

RAILWAY_URL = "https://astroyorumai-production.up.railway.app"

def test_health():
    """Test Railway health endpoint"""
    print("🏥 Testing Railway Health Endpoint...")
    try:
        response = requests.get(f"{RAILWAY_URL}/health", timeout=30)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health Status: {data.get('status')}")
            print(f"✅ Version: {data.get('version')}")
            print(f"✅ Service: {data.get('service')}")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_natal():
    """Test Railway natal endpoint"""
    print("\n🌟 Testing Railway Natal Endpoint...")
    try:
        payload = {
            "date": "1990-06-15",
            "time": "14:30", 
            "latitude": 41.0082,
            "longitude": 28.9784
        }
        
        response = requests.post(
            f"{RAILWAY_URL}/natal",
            json=payload,
            headers={'Content-Type': 'application/json'},
            timeout=60
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Natal calculation successful")
            print(f"✅ Planets found: {len(data.get('planets', {}))}")
            print(f"✅ Ascendant: {data.get('ascendant')}")
            print(f"✅ Method: {data.get('calculation_method')}")
            return True
        else:
            print(f"❌ Natal calculation failed: {response.status_code}")
            print(f"❌ Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Natal test error: {e}")
        return False

def main():
    """Run all Railway deployment tests"""
    print("🚂 Railway Production Deployment Test")
    print("=" * 50)
    
    tests = [
        ("Health Check", test_health),
        ("Natal Calculation", test_natal),
    ]
    
    results = []
    for test_name, test_func in tests:
        print(f"\n🧪 Running: {test_name}")
        result = test_func()
        results.append((test_name, result))
        time.sleep(2)
    
    print("\n" + "=" * 50)
    print("🎯 RAILWAY DEPLOYMENT TEST RESULTS")
    print("=" * 50)
    
    passed = 0
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} {test_name}")
        if result:
            passed += 1
    
    success_rate = (passed / len(tests)) * 100
    print(f"\n📊 Success Rate: {success_rate:.1f}% ({passed}/{len(tests)})")
    
    if success_rate == 100:
        print("🎉 Railway deployment is fully functional!")
        return 0
    else:
        print("❌ Railway deployment has issues")
        return 1

if __name__ == "__main__":
    sys.exit(main())