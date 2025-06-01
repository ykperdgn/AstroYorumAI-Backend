#!/usr/bin/env python3
"""
Test flatlib integration locally to verify our code works
"""
import sys
import os

# Add current directory to path so we can import app
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def test_flatlib_locally():
    print("🧪 Testing Flatlib Integration Locally")
    print("=" * 40)
    
    # Test 1: Check if flatlib can be imported
    try:
        from flatlib.datetime import Datetime
        from flatlib.geopos import GeoPos
        from flatlib.chart import Chart
        from flatlib import const
        print("✅ Flatlib import successful")
        
        # Test 2: Create a simple chart
        print("🔮 Creating test natal chart...")
        
        date_time = Datetime('1990/01/15 14:30', '+00:00')
        pos = GeoPos(40.7128, -74.0060)  # New York
        chart = Chart(date_time, pos)
        
        # Test 3: Get planetary positions
        print("🪐 Getting planetary positions...")
        
        sun = chart.get(const.SUN)
        moon = chart.get(const.MOON)
        
        print(f"   Sun: {sun.sign} {sun.signlon:.2f}°")
        print(f"   Moon: {moon.sign} {moon.signlon:.2f}°")
        
        print("✅ Flatlib calculations working!")
        return True
        
    except ImportError as e:
        print(f"❌ Flatlib import failed: {e}")
        print("💡 Try: pip install flatlib")
        return False
    except Exception as e:
        print(f"❌ Flatlib calculation failed: {e}")
        return False

def test_app_endpoint_locally():
    print("\n🌐 Testing App Endpoint Locally")
    print("=" * 40)
    
    try:
        # Import our app
        from app import app
        
        # Create test client
        with app.test_client() as client:
            # Test natal endpoint
            test_data = {
                "date": "1990-01-15",
                "time": "14:30", 
                "latitude": 40.7128,
                "longitude": -74.0060
            }
            
            response = client.post('/natal', json=test_data)
            
            print(f"📡 Status Code: {response.status_code}")
            
            if response.status_code == 200:
                data = response.get_json()
                print("✅ Local endpoint working!")
                
                if "planets" in data:
                    print("🪐 Planets found in response:")
                    for planet, info in data.get("planets", {}).items():
                        print(f"   {planet}: {info}")
                    return True
                else:
                    print("❌ No planets in response")
                    print(f"📄 Response: {data}")
                    return False
            else:
                print(f"❌ Request failed: {response.data}")
                return False
                
    except Exception as e:
        print(f"❌ Local test failed: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Local Flatlib Integration Test")
    print("=" * 50)
    
    flatlib_ok = test_flatlib_locally()
    app_ok = test_app_endpoint_locally()
    
    print("\n📊 Test Results:")
    print(f"   Flatlib: {'✅ PASS' if flatlib_ok else '❌ FAIL'}")
    print(f"   App Endpoint: {'✅ PASS' if app_ok else '❌ FAIL'}")
    
    if flatlib_ok and app_ok:
        print("\n🎉 All tests passed! Ready for deployment.")
    else:
        print("\n❌ Some tests failed. Check dependencies and code.")
