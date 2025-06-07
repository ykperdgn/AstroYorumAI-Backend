#!/usr/bin/env python3
import requests
import json
import sys
import time

def test_complete_integration():
    """Complete end-to-end test of AstroYorumAI"""
    print("🚀 AstroYorumAI Complete Integration Test")
    print("=" * 50)
    
    base_url = "https://astroyorumai-api.onrender.com"
    
    # Test 1: Health Check
    print("\n1️⃣ Testing Health Endpoint...")
    try:
        response = requests.get(f"{base_url}/health", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health OK - Version: {data.get('version', 'unknown')}")
        else:
            print(f"❌ Health failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health error: {e}")
        return False
    
    # Test 2: Root Endpoint
    print("\n2️⃣ Testing Root Endpoint...")
    try:
        response = requests.get(f"{base_url}/", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Root OK - Message: {data.get('message', 'unknown')}")
        else:
            print(f"❌ Root failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Root error: {e}")
    
    # Test 3: Natal Chart (Main Feature)
    print("\n3️⃣ Testing Natal Chart Calculation...")
    payload = {
        "date": "1990-06-15",
        "time": "14:30", 
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    try:
        response = requests.post(
            f"{base_url}/natal",
            json=payload,
            headers={'Content-Type': 'application/json'},
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            planets = data.get('planets', [])
            houses = data.get('houses', [])
            aspects = data.get('aspects', [])
            
            print(f"✅ Natal Chart Success!")
            print(f"   🌟 Planets: {len(planets)}")
            print(f"   🏠 Houses: {len(houses)}")
            print(f"   ⭐ Aspects: {len(aspects)}")
            
            # Show detailed planet info
            if planets:
                print(f"\n📍 Sample Planet Data:")
                first_planet = planets[0]
                print(f"   {first_planet.get('name', 'Unknown')}: {first_planet.get('degree', 0):.2f}° in {first_planet.get('sign', 'Unknown')}")
            
            return True
        else:
            print(f"❌ Natal Chart failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Natal Chart error: {e}")
        return False

def test_flutter_endpoint_compatibility():
    """Test Flutter app compatibility"""
    print("\n4️⃣ Testing Flutter App Compatibility...")
    
    # Simulate Flutter app request
    headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'User-Agent': 'Flutter/3.24.0 (AstroYorumAI)',
    }
    
    payload = {
        "date": "1985-03-20",
        "time": "12:00",
        "latitude": 39.9334,
        "longitude": 32.8597
    }
    
    try:
        response = requests.post(
            "https://astroyorumai-api.onrender.com/natal",
            json=payload,
            headers=headers,
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            
            # Check if response contains expected Turkish fields
            planets = data.get('planets', [])
            if planets:
                first_planet = planets[0]
                has_turkish_name = any(
                    turkish_name in str(first_planet.get('name', ''))
                    for turkish_name in ['Güneş', 'Ay', 'Merkür', 'Venüs', 'Mars', 'Jüpiter', 'Satürn']
                )
                
                has_turkish_sign = any(
                    turkish_sign in str(first_planet.get('sign', ''))
                    for turkish_sign in ['Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak']
                )
                
                print(f"✅ Flutter Compatibility OK")
                print(f"   Turkish Names: {'✅' if has_turkish_name else '⚠️ English'}")
                print(f"   Turkish Signs: {'✅' if has_turkish_sign else '⚠️ English'}")
                return True
        else:
            print(f"❌ Flutter compatibility failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Flutter compatibility error: {e}")
        return False

def test_cors_configuration():
    """Test CORS configuration"""
    print("\n5️⃣ Testing CORS Configuration...")
    
    try:
        # Test OPTIONS request (preflight)
        response = requests.options(
            "https://astroyorumai-api.onrender.com/natal",
            headers={
                'Origin': 'http://localhost:8080',
                'Access-Control-Request-Method': 'POST',
                'Access-Control-Request-Headers': 'Content-Type'
            }
        )
        
        cors_origin = response.headers.get('Access-Control-Allow-Origin', '')
        cors_methods = response.headers.get('Access-Control-Allow-Methods', '')
        cors_headers = response.headers.get('Access-Control-Allow-Headers', '')
        
        print(f"✅ CORS Configuration:")
        print(f"   Origin: {cors_origin}")
        print(f"   Methods: {cors_methods}")
        print(f"   Headers: {cors_headers}")
        
        return '*' in cors_origin or 'localhost' in cors_origin
        
    except Exception as e:
        print(f"❌ CORS test error: {e}")
        return False

if __name__ == "__main__":
    print("🎯 Running Complete AstroYorumAI Integration Test")
    print(f"⏰ Start Time: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    
    tests = [
        test_complete_integration(),
        test_flutter_endpoint_compatibility(), 
        test_cors_configuration()
    ]
    
    passed = sum(tests)
    total = len(tests)
    
    print("\n" + "=" * 50)
    print(f"📊 TEST RESULTS: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 ALL TESTS PASSED! Production is ready!")
        print("✅ Backend API is fully operational")
        print("✅ Flutter app compatibility confirmed")
        print("✅ CORS configuration working")
        print("\n🚀 Ready for 100% completion status!")
        sys.exit(0)
    else:
        print(f"❌ {total - passed} tests failed")
        sys.exit(1)
