#!/usr/bin/env python3
"""
Beta Testing Production Deployment Verification
Tests all API endpoints for AstroYorumAI beta testing
"""

import requests
import json
import sys
from datetime import datetime

BASE_URL = "https://astroyorumai-api.onrender.com"

def test_endpoint(endpoint, method="GET", data=None):
    """Test a single API endpoint"""
    url = f"{BASE_URL}{endpoint}"
    print(f"\n🔍 Testing {method} {endpoint}")
    
    try:
        if method == "GET":
            response = requests.get(url, timeout=30)
        elif method == "POST":
            response = requests.post(url, json=data, timeout=30)
        
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"   ✅ SUCCESS")
            if 'version' in result:
                print(f"   Version: {result['version']}")
            return True, result
        else:
            print(f"   ❌ FAILED: {response.text[:100]}")
            return False, None
            
    except Exception as e:
        print(f"   💥 ERROR: {str(e)}")
        return False, None

def main():
    print("🚀 AstroYorumAI Beta Testing Deployment Verification")
    print(f"📅 Test Date: {datetime.now().isoformat()}")
    print(f"🌐 Testing API: {BASE_URL}")
    print("=" * 60)
    
    tests = []
    
    # Test 1: Root endpoint
    success, data = test_endpoint("/")
    tests.append(("Root endpoint", success))
    
    # Test 2: Health check
    success, data = test_endpoint("/health")
    tests.append(("Health check", success))
    
    # Test 3: Test endpoint
    success, data = test_endpoint("/test")
    tests.append(("Test endpoint", success))
    
    # Test 4: Status endpoint (if available)
    success, data = test_endpoint("/status")
    tests.append(("Status endpoint", success))
    
    # Test 5: Natal chart endpoint
    natal_data = {
        "date": "1990-06-15",
        "time": "14:30", 
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    success, data = test_endpoint("/natal", method="POST", data=natal_data)
    tests.append(("Natal chart calculation", success))
    
    if success and data:
        print(f"\n📊 Natal Chart Response Preview:")
        print(f"   Planets: {len(data.get('planets', {}))}")
        print(f"   Ascendant: {data.get('ascendant', 'N/A')}")
        print(f"   Message: {data.get('message', 'N/A')}")
    
    # Results summary
    print("\n" + "=" * 60)
    print("📋 TEST RESULTS SUMMARY")
    print("=" * 60)
    
    passed = 0
    total = len(tests)
    
    for test_name, success in tests:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {test_name}")
        if success:
            passed += 1
    
    print(f"\n📊 Overall: {passed}/{total} tests passed ({passed/total*100:.1f}%)")
    
    if passed == total:
        print("\n🎉 ALL TESTS PASSED - READY FOR BETA TESTING!")
        print("✅ Backend API is fully functional")
        print("✅ Natal chart calculations working")
        print("✅ Production deployment successful")
        return True
    else:
        print(f"\n⚠️  {total-passed} tests failed - Review issues before beta launch")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
