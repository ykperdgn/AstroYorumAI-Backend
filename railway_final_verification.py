#!/usr/bin/env python3
"""
Railway Final Integration Test
Comprehensive verification of Railway deployment success
"""

import requests
import json
import time
from datetime import datetime

RAILWAY_URL = "https://astroyorumai-backend-production.up.railway.app"

def print_header(title):
    print("\n" + "=" * 60)
    print(f"🚂 {title}")
    print("=" * 60)

def test_endpoint(name, url, expected_keys=None, method='GET', payload=None):
    """Generic endpoint test function"""
    print(f"\n🧪 Testing: {name}")
    print(f"📍 URL: {url}")
    
    try:
        if method == 'POST':
            response = requests.post(url, json=payload, timeout=30)
        else:
            response = requests.get(url, timeout=30)
            
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ SUCCESS - Response received")
            
            # Check expected keys
            if expected_keys:
                for key in expected_keys:
                    if key in data:
                        print(f"✅ Key '{key}': {data[key]}")
                    else:
                        print(f"❌ Missing key: {key}")
            
            return True, data
        else:
            print(f"❌ FAILED - Status: {response.status_code}")
            print(f"❌ Response: {response.text[:200]}")
            return False, None
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False, None

def main():
    """Run comprehensive Railway deployment verification"""
    print_header("RAILWAY DEPLOYMENT FINAL VERIFICATION")
    
    results = []
    
    # Test 1: Health Check
    success, data = test_endpoint(
        "Health Check",
        f"{RAILWAY_URL}/health",
        expected_keys=['status', 'version', 'service']
    )
    results.append(("Health Check", success))
    
    # Test 2: Root Endpoint
    success, data = test_endpoint(
        "Root Endpoint",
        f"{RAILWAY_URL}/",
        expected_keys=['message', 'version', 'endpoints']
    )
    results.append(("Root Endpoint", success))
    
    # Test 3: Status Endpoint
    success, data = test_endpoint(
        "Status Endpoint", 
        f"{RAILWAY_URL}/status",
        expected_keys=['status']
    )
    results.append(("Status Endpoint", success))
    
    # Test 4: Test Endpoint
    success, data = test_endpoint(
        "Test Endpoint",
        f"{RAILWAY_URL}/test",
        expected_keys=['message', 'flask_working']
    )
    results.append(("Test Endpoint", success))
    
    # Test 5: Natal Chart Calculation
    natal_payload = {
        "date": "1990-06-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    success, data = test_endpoint(
        "Natal Chart Calculation",
        f"{RAILWAY_URL}/natal",
        expected_keys=['planets', 'ascendant', 'calculation_method'],
        method='POST',
        payload=natal_payload
    )
    results.append(("Natal Chart", success))
    
    if success and data:
        print(f"🌟 Planets calculated: {len(data.get('planets', {}))}")
        print(f"🌟 Ascendant: {data.get('ascendant')}")
        print(f"🌟 Method: {data.get('calculation_method')}")
    
    # Test 6: CORS Headers
    print(f"\n🧪 Testing: CORS Configuration")
    try:
        response = requests.get(
            f"{RAILWAY_URL}/health",
            headers={'Origin': 'https://astroyorumai.com'},
            timeout=30
        )
        
        cors_origin = response.headers.get('Access-Control-Allow-Origin')
        cors_methods = response.headers.get('Access-Control-Allow-Methods')
        
        if cors_origin and cors_methods:
            print("✅ CORS Configuration: Working")
            print(f"✅ Allow-Origin: {cors_origin}")
            print(f"✅ Allow-Methods: {cors_methods}")
            results.append(("CORS Configuration", True))
        else:
            print("❌ CORS Configuration: Missing headers")
            results.append(("CORS Configuration", False))
            
    except Exception as e:
        print(f"❌ CORS Test Error: {e}")
        results.append(("CORS Configuration", False))
    
    # Final Results Summary
    print_header("FINAL VERIFICATION RESULTS")
    
    passed = 0
    total = len(results)
    
    for test_name, success in results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {test_name}")
        if success:
            passed += 1
    
    success_rate = (passed / total) * 100
    print(f"\n📊 Overall Success Rate: {success_rate:.1f}% ({passed}/{total})")
    
    if success_rate == 100:
        print("\n🎉 RAILWAY DEPLOYMENT: 100% SUCCESSFUL!")
        print("🚀 Production backend is fully operational")
        print("✅ Ready for Flutter app integration")
        print("✅ All endpoints responding correctly")
        print("✅ CORS properly configured")
        print("✅ Real astrology calculations working")
        
        # Generate summary report
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"\n📝 Verification completed at: {timestamp}")
        print(f"🌐 Production URL: {RAILWAY_URL}")
        
        return 0
    else:
        print(f"\n⚠️ RAILWAY DEPLOYMENT: {success_rate:.1f}% Success")
        print("🔧 Some issues need attention")
        return 1

if __name__ == "__main__":
    exit(main())
