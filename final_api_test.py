#!/usr/bin/env python3
"""
Comprehensive test for the deployed AstroYorumAI API on Render.com
"""
import requests
import json
import time

BASE_URL = "https://astroyorumai-api.onrender.com"

def test_endpoint(endpoint, method="GET", data=None):
    """Test a specific endpoint"""
    url = f"{BASE_URL}{endpoint}"
    print(f"\n🔍 Testing {method} {url}")
    
    try:
        if method == "GET":
            response = requests.get(url, timeout=30)
        elif method == "POST":
            response = requests.post(url, json=data, timeout=30)
        
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            print(f"   ✅ Success")
            try:
                json_data = response.json()
                print(f"   Response: {json.dumps(json_data, indent=2)[:200]}...")
                return True, json_data
            except:
                print(f"   Response: {response.text[:200]}...")
                return True, response.text
        else:
            print(f"   ❌ Failed: {response.text[:200]}")
            return False, response.text
            
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return False, str(e)

def main():
    print("🚀 Comprehensive AstroYorumAI API Test")
    print("="*50)
    
    # Wait for service to wake up
    print("\n⏳ Waking up the service...")
    time.sleep(10)
    
    tests_passed = 0
    total_tests = 0
    
    # Test 1: Root endpoint
    total_tests += 1
    success, _ = test_endpoint("/")
    if success:
        tests_passed += 1
    
    # Test 2: Health endpoint
    total_tests += 1
    success, _ = test_endpoint("/health")
    if success:
        tests_passed += 1
    
    # Test 3: Test endpoint
    total_tests += 1
    success, _ = test_endpoint("/test")
    if success:
        tests_passed += 1
    
    # Test 4: Natal chart endpoint (POST)
    total_tests += 1
    natal_data = {
        "date": "1990-01-01",
        "time": "12:00",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    success, response = test_endpoint("/natal", method="POST", data=natal_data)
    if success:
        tests_passed += 1
        print(f"   🌟 Natal chart response preview: {str(response)[:100]}...")
    
    # Summary
    print("\n" + "="*50)
    print(f"📊 Test Results: {tests_passed}/{total_tests} tests passed")
    
    if tests_passed == total_tests:
        print("🎉 ALL TESTS PASSED! The API is working perfectly!")
        print(f"🌐 API URL: {BASE_URL}")
        print("✅ Ready for production use!")
    else:
        print(f"⚠️  {total_tests - tests_passed} tests failed")
    
    return tests_passed == total_tests

if __name__ == "__main__":
    main()
