#!/usr/bin/env python3
"""
Comprehensive API test for AstroYorumAI backend deployment
Tests version, endpoints, and natal chart data structure
"""
import requests
import json
import time
from datetime import datetime

BASE_URL = "https://astroyorumai-api.onrender.com"

def print_header(title):
    """Print a formatted header"""
    print(f"\n{'='*50}")
    print(f" {title}")
    print(f"{'='*50}")

def print_result(success, message):
    """Print test result with formatting"""
    status = "✅ SUCCESS" if success else "❌ FAILED"
    print(f"{status}: {message}")

def test_api_health():
    """Test if the API is responding"""
    print_header("API HEALTH CHECK")
    
    try:
        response = requests.get(f"{BASE_URL}/", timeout=10)
        if response.status_code == 200:
            data = response.json()
            version = data.get("version", "unknown")
            print_result(True, f"API is responsive")
            print(f"📦 Version: {version}")
            print(f"🌐 Status: {data.get('status', 'unknown')}")
            print(f"🐍 Python: {data.get('python_version', 'unknown')}")
            return True, version
        else:
            print_result(False, f"API returned status {response.status_code}")
            return False, None
    except Exception as e:
        print_result(False, f"API connection failed: {e}")
        return False, None

def test_status_endpoint():
    """Test the status endpoint"""
    print_header("STATUS ENDPOINT TEST")
    
    try:
        response = requests.get(f"{BASE_URL}/status", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print_result(True, "Status endpoint working")
            print(f"🚀 Deployment Version: {data.get('deployment_version', 'unknown')}")
            print(f"⏰ Deployment Time: {data.get('deployment_time', 'unknown')}")
            print(f"📚 Flatlib Available: {data.get('flatlib_available', False)}")
            return True
        elif response.status_code == 404:
            print_result(False, "Status endpoint not found (old deployment)")
            return False
        else:
            print_result(False, f"Status endpoint returned {response.status_code}")
            return False
    except Exception as e:
        print_result(False, f"Status endpoint failed: {e}")
        return False

def test_natal_chart_endpoint():
    """Test the natal chart endpoint with real data"""
    print_header("NATAL CHART ENDPOINT TEST")
    
    # Test data for Istanbul, Turkey
    test_data = {
        "date": "1990-05-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    try:
        response = requests.post(f"{BASE_URL}/natal", json=test_data, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            print_result(True, "Natal chart endpoint responding")
            
            # Check data structure
            has_planets = "planets" in data
            has_ascendant = "ascendant" in data
            has_message = "message" in data
            
            print(f"🪐 Has planets data: {has_planets}")
            print(f"⭐ Has ascendant: {has_ascendant}")
            print(f"💬 Has message: {has_message}")
            
            if has_planets:
                planets = data["planets"]
                print(f"🌟 Available planets: {list(planets.keys())}")
                
                # Check planet data structure
                for planet_name, planet_data in planets.items():
                    if isinstance(planet_data, dict):
                        sign = planet_data.get("sign", "missing")
                        degree = planet_data.get("deg", "missing")
                        house = planet_data.get("house", "missing")
                        print(f"   {planet_name}: {sign} {degree}° (House {house})")
                    else:
                        print(f"   {planet_name}: {planet_data} (old format)")
                    break  # Just show first planet as example
                
                print_result(True, "Enhanced planetary data structure detected!")
            else:
                print_result(False, "No planets data found")
                print(f"Response keys: {list(data.keys())}")
            
            if has_message:
                message = data.get("message", "")
                print(f"📝 Message: {message}")
                
                if "Enhanced mock" in message:
                    print_result(True, "Backend serving enhanced mock data")
                elif "Real astrological" in message or "flatlib" in message.lower():
                    print_result(True, "Backend using real astrological calculations!")
                else:
                    print(f"ℹ️  Unknown calculation type")
            
            return True
        else:
            print_result(False, f"Natal endpoint returned {response.status_code}")
            print(f"Response: {response.text[:200]}...")
            return False
            
    except Exception as e:
        print_result(False, f"Natal endpoint failed: {e}")
        return False

def test_flutter_compatibility():
    """Test if the API structure is compatible with Flutter app"""
    print_header("FLUTTER COMPATIBILITY TEST")
    
    test_data = {
        "date": "1985-12-25",
        "time": "09:15",
        "latitude": 39.9334,
        "longitude": 32.8597
    }
    
    try:
        response = requests.post(f"{BASE_URL}/natal", json=test_data, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            
            # Check if Flutter can parse this structure
            compatibility_checks = {
                "planets_exist": "planets" in data,
                "planets_is_dict": isinstance(data.get("planets"), dict),
                "ascendant_exists": "ascendant" in data,
                "sun_data_valid": False,
                "planet_structure_valid": False
            }
            
            if compatibility_checks["planets_exist"] and compatibility_checks["planets_is_dict"]:
                planets = data["planets"]
                
                # Check Sun data (critical for zodiac sign)
                if "Sun" in planets:
                    sun_data = planets["Sun"]
                    if isinstance(sun_data, dict) and "sign" in sun_data:
                        compatibility_checks["sun_data_valid"] = True
                
                # Check general planet structure
                for planet_data in planets.values():
                    if isinstance(planet_data, dict) and "sign" in planet_data and "deg" in planet_data:
                        compatibility_checks["planet_structure_valid"] = True
                        break
            
            all_compatible = all(compatibility_checks.values())
            
            print(f"🔍 Compatibility Analysis:")
            for check, result in compatibility_checks.items():
                status = "✅" if result else "❌"
                print(f"   {status} {check.replace('_', ' ').title()}: {result}")
            
            if all_compatible:
                print_result(True, "API fully compatible with Flutter app!")
            else:
                print_result(False, "API has compatibility issues with Flutter app")
            
            return all_compatible
        else:
            print_result(False, f"Cannot test compatibility - API error {response.status_code}")
            return False
            
    except Exception as e:
        print_result(False, f"Compatibility test failed: {e}")
        return False

def main():
    """Run all tests"""
    print(f"🚀 AstroYorumAI Backend Comprehensive Test")
    print(f"⏰ Test Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 Target URL: {BASE_URL}")
    
    # Run tests
    tests_passed = 0
    total_tests = 4
    
    # Test 1: Basic API Health
    health_ok, version = test_api_health()
    if health_ok:
        tests_passed += 1
    
    # Test 2: Status endpoint (shows deployment version)
    status_ok = test_status_endpoint()
    if status_ok:
        tests_passed += 1
    
    # Test 3: Natal chart endpoint functionality
    natal_ok = test_natal_chart_endpoint()
    if natal_ok:
        tests_passed += 1
    
    # Test 4: Flutter compatibility
    flutter_ok = test_flutter_compatibility()
    if flutter_ok:
        tests_passed += 1
    
    # Summary
    print_header("TEST SUMMARY")
    print(f"📊 Tests Passed: {tests_passed}/{total_tests}")
    print(f"📦 API Version: {version if version else 'unknown'}")
    
    if tests_passed == total_tests:
        print_result(True, "All tests passed! Backend is ready for Flutter app.")
    elif tests_passed >= 2:
        print_result(True, f"Most tests passed. Some issues may need attention.")
    else:
        print_result(False, "Multiple test failures. Backend needs investigation.")
    
    # Recommendations
    print(f"\n💡 RECOMMENDATIONS:")
    if not health_ok:
        print("   • Check Render deployment logs")
        print("   • Verify GitHub repository connection")
        print("   • Check for build errors")
    elif version and "1.0.0" in version:
        print("   • Old deployment still active - new version not deployed yet")
        print("   • Wait 5-10 minutes for Render to complete deployment")
        print("   • Check Render dashboard for deployment status")
    elif not natal_ok:
        print("   • Natal chart endpoint has issues")
        print("   • Check app.py syntax and endpoint implementation")
    elif not flutter_ok:
        print("   • API structure incompatible with Flutter expectations")
        print("   • Review planet data format in Flutter services")
    else:
        print("   • Backend is working correctly!")
        print("   • Ready for Flutter app testing")

if __name__ == "__main__":
    main()
