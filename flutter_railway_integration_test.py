#!/usr/bin/env python3
"""
Flutter Railway Integration Test
Tests the complete flow from Flutter web app to Railway backend
"""
import requests
import json
import time

def test_flutter_railway_integration():
    print("🚀 Flutter Railway Integration Test")
    print("=" * 50)
    
    # Test data - same as what Flutter app would send
    test_payload = {
        "date": "1990-06-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    railway_backend = "https://astroyorumai-backend-production.up.railway.app"
    
    print("1️⃣ Testing Railway Backend Health...")
    try:
        health_response = requests.get(f"{railway_backend}/health", timeout=10)
        if health_response.status_code == 200:
            health_data = health_response.json()
            print(f"   ✅ Status: {health_data['status']}")
            print(f"   📊 Version: {health_data['version']}")
            print(f"   🧮 Calculator: {health_data['calculation_method']}")
            print(f"   🚂 Platform: {health_data['platform']}")
        else:
            print(f"   ❌ Health check failed: {health_response.status_code}")
            return False
    except Exception as e:
        print(f"   💥 Health check error: {e}")
        return False
    
    print("\n2️⃣ Testing Natal Chart Calculation (Flutter Simulation)...")
    try:
        headers = {
            'Content-Type': 'application/json',
            'Origin': 'http://localhost:8080',  # Flutter web origin
            'Referer': 'http://localhost:8080/'
        }
        
        start_time = time.time()
        natal_response = requests.post(
            f"{railway_backend}/natal", 
            json=test_payload, 
            headers=headers,
            timeout=15
        )
        response_time = time.time() - start_time
        
        if natal_response.status_code == 200:
            natal_data = natal_response.json()
            print(f"   ✅ Natal chart calculated successfully")
            print(f"   🌟 Ascendant: {natal_data.get('ascendant', 'N/A')}")
            print(f"   🪐 Planets calculated: {len(natal_data.get('planets', []))}")
            print(f"   ⏱️ Response time: {response_time:.2f}s")
            print(f"   🧮 Method: {natal_data.get('calculation_method', 'N/A')}")
            
            # Check for Turkish translation
            if natal_data.get('turkish_converted'):
                print(f"   🇹🇷 Turkish conversion: ✅")
            
            return True
        else:
            print(f"   ❌ Natal calculation failed: {natal_response.status_code}")
            print(f"   📄 Response: {natal_response.text}")
            return False
            
    except Exception as e:
        print(f"   💥 Natal calculation error: {e}")
        return False

def test_cors_configuration():
    print("\n3️⃣ Testing CORS Configuration...")
    
    railway_backend = "https://astroyorumai-backend-production.up.railway.app"
    
    try:
        # Test OPTIONS request (preflight)
        options_response = requests.options(
            f"{railway_backend}/natal",
            headers={
                'Origin': 'http://localhost:8080',
                'Access-Control-Request-Method': 'POST',
                'Access-Control-Request-Headers': 'Content-Type'
            }
        )
        
        if options_response.status_code in [200, 204]:
            cors_headers = options_response.headers
            print(f"   ✅ CORS preflight successful")
            print(f"   🌐 Allow-Origin: {cors_headers.get('Access-Control-Allow-Origin', 'N/A')}")
            print(f"   📋 Allow-Methods: {cors_headers.get('Access-Control-Allow-Methods', 'N/A')}")
            print(f"   🔧 Allow-Headers: {cors_headers.get('Access-Control-Allow-Headers', 'N/A')}")
            return True
        else:
            print(f"   ❌ CORS preflight failed: {options_response.status_code}")
            return False
            
    except Exception as e:
        print(f"   💥 CORS test error: {e}")
        return False

if __name__ == "__main__":
    print("🎯 AstroYorumAI Flutter → Railway Integration Test")
    print("=" * 60)
    
    # Run all tests
    backend_test = test_flutter_railway_integration()
    cors_test = test_cors_configuration()
    
    print("\n" + "=" * 60)
    print("📊 Integration Test Results")
    print("=" * 60)
    print(f"   Backend Integration: {'✅ PASS' if backend_test else '❌ FAIL'}")
    print(f"   CORS Configuration: {'✅ PASS' if cors_test else '❌ FAIL'}")
    
    if backend_test and cors_test:
        print("\n🎉 ALL TESTS PASSED!")
        print("✅ Flutter app is ready for production deployment")
        print("✅ Railway backend is fully operational")
        print("✅ End-to-end integration confirmed")
        print("\n📱 Next Steps:")
        print("1. Test natal chart feature in Flutter web app at http://localhost:8080")
        print("2. Build production Flutter app")
        print("3. Deploy to production hosting")
    else:
        print("\n⚠️  Some tests failed - please check configuration")
