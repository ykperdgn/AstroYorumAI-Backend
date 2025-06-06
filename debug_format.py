#!/usr/bin/env python3
"""
Debug API response format for Flutter compatibility
"""
import requests
import json

def test_api_format():
    """Test the API response format and structure"""
    url = "https://astroyorumai-api.onrender.com/natal"
    
    test_data = {
        'date': '1990-05-15',
        'time': '14:30',
        'latitude': 41.0082,
        'longitude': 28.9784
    }
    
    try:
        print("🔍 Testing API response format...")
        response = requests.post(url, json=test_data, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            
            print("✅ API Response Structure:")
            print(f"   Status Code: {response.status_code}")
            print(f"   Response Keys: {list(data.keys())}")
            
            if 'planets' in data:
                planets = data['planets']
                print(f"   Planets: {list(planets.keys())}")
                
                # Check planet data structure
                for planet_name, planet_data in planets.items():
                    print(f"   {planet_name}: {planet_data}")
                    break  # Just show first planet
                
                print(f"\n🔍 FLUTTER COMPATIBILITY CHECK:")
                print(f"   ✅ Has 'planets' key: {'planets' in data}")
                print(f"   ✅ Planets is dict: {isinstance(planets, dict)}")
                
                # Check first planet structure
                if planets:
                    first_planet = list(planets.keys())[0]
                    first_data = planets[first_planet]
                    print(f"   ✅ Planet data type: {type(first_data)}")
                    
                    if isinstance(first_data, dict):
                        print(f"   ✅ Has 'sign': {'sign' in first_data}")
                        print(f"   ✅ Has 'deg': {'deg' in first_data}")
                        print(f"   🎯 Sample planet: {first_planet} = {first_data}")
                    else:
                        print(f"   ❌ Planet data is not dict: {first_data}")
                
                print(f"\n📊 FULL RESPONSE:")
                print(json.dumps(data, indent=2))
                
            else:
                print("   ❌ No 'planets' key in response")
                print(f"   Response: {data}")
                
        else:
            print(f"❌ API Error: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Request failed: {e}")

if __name__ == "__main__":
    test_api_format()
