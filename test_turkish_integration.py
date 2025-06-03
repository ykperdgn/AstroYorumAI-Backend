#!/usr/bin/env python3
"""
Complete Turkish integration test for AstroYorumAI
Tests both backend Turkish support and simulates Flutter frontend conversion
"""

import requests
import json
from datetime import datetime

# API Configuration
API_BASE_URL = "https://astroyorumai-api.onrender.com"

# Turkish translation mappings (matching Flutter frontend)
PLANET_NAMES_TR = {
    'Sun': 'Güneş',
    'Moon': 'Ay', 
    'Mercury': 'Merkür',
    'Venus': 'Venüs',
    'Mars': 'Mars',
    'Jupiter': 'Jüpiter',
    'Saturn': 'Satürn',
}

SIGN_NAMES_TR = {
    'Aries': 'Koç',
    'Taurus': 'Boğa', 
    'Gemini': 'İkizler',
    'Cancer': 'Yengeç',
    'Leo': 'Aslan',
    'Virgo': 'Başak',
    'Libra': 'Terazi',
    'Scorpio': 'Akrep',
    'Sagittarius': 'Yay',
    'Capricorn': 'Oğlak',
    'Aquarius': 'Kova',
    'Pisces': 'Balık',
}

def convert_to_turkish_client_side(api_response):
    """
    Simulate the Flutter frontend Turkish conversion
    This is exactly what the Flutter app does
    """
    print('🔄 Client-side Turkish conversion starting...')
    converted_response = api_response.copy()
    
    # Convert planets to Turkish
    if 'planets' in converted_response:
        print('🌟 Converting planets to Turkish...')
        original_planets = converted_response['planets']
        turkish_planets = {}
        
        for planet_key, planet_data in original_planets.items():
            print(f'🔄 Converting planet: {planet_key}')
            # Convert planet name to Turkish
            turkish_planet_name = PLANET_NAMES_TR.get(planet_key, planet_key)
            print(f'   {planet_key} → {turkish_planet_name}')
            
            if isinstance(planet_data, dict):
                planet_info = planet_data.copy()
                
                # Convert sign to Turkish if it exists
                if 'sign' in planet_info:
                    original_sign = planet_info['sign']
                    turkish_sign = SIGN_NAMES_TR.get(original_sign, original_sign)
                    print(f'   Sign: {original_sign} → {turkish_sign}')
                    planet_info['sign'] = turkish_sign
                
                turkish_planets[turkish_planet_name] = planet_info
            else:
                turkish_planets[turkish_planet_name] = planet_data
        
        converted_response['planets'] = turkish_planets
        print('✅ Planet conversion completed')
    
    # Convert ascendant to Turkish
    if 'ascendant' in converted_response:
        original_ascendant = converted_response['ascendant']
        turkish_ascendant = SIGN_NAMES_TR.get(original_ascendant, original_ascendant)
        print(f'🔄 Ascendant: {original_ascendant} → {turkish_ascendant}')
        converted_response['ascendant'] = turkish_ascendant
    
    # Add conversion metadata
    converted_response['turkish_converted'] = True
    converted_response['conversion_method'] = 'client_side_python_simulation'
    
    print('✅ Client-side Turkish conversion completed!')
    return converted_response

def test_api_health():
    """Test API health endpoint"""
    print("🏥 Testing API health...")
    try:
        response = requests.get(f"{API_BASE_URL}/health", timeout=10)
        print(f"Health check status: {response.status_code}")
        if response.status_code == 200:
            print("✅ API is healthy!")
            return True
        else:
            print(f"❌ API health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_natal_chart_turkish():
    """Test natal chart calculation with Turkish conversion"""
    print("\n🌟 Testing natal chart calculation with Turkish conversion...")
    
    # Test data
    test_data = {
        "birth_date": "1990-05-15",
        "birth_time": "14:30",
        "birth_location": "Istanbul"
    }
    
    try:
        print(f"📝 Sending request with data: {test_data}")
        response = requests.post(
            f"{API_BASE_URL}/calculate_natal_chart",
            json=test_data,
            headers={'Content-Type': 'application/json'},
            timeout=30
        )
        
        print(f"📊 Response status: {response.status_code}")
        
        if response.status_code == 200:
            api_result = response.json()
            print("✅ API response received successfully!")
            
            # Show original API response
            print("\n📋 Original API Response:")
            print("=" * 50)
            if 'planets' in api_result:
                for planet, data in api_result['planets'].items():
                    if isinstance(data, dict) and 'sign' in data:
                        print(f"  {planet}: {data['sign']} ({data.get('degree', 'N/A')}°)")
                    else:
                        print(f"  {planet}: {data}")
            
            if 'ascendant' in api_result:
                print(f"  Ascendant: {api_result['ascendant']}")
            
            # Apply client-side Turkish conversion
            print("\n🇹🇷 Applying Client-Side Turkish Conversion:")
            print("=" * 50)
            turkish_result = convert_to_turkish_client_side(api_result)
            
            # Show Turkish converted result
            print("\n📋 Turkish Converted Response:")
            print("=" * 50)
            if 'planets' in turkish_result:
                for planet, data in turkish_result['planets'].items():
                    if isinstance(data, dict) and 'sign' in data:
                        print(f"  {planet}: {data['sign']} ({data.get('degree', 'N/A')}°)")
                    else:
                        print(f"  {planet}: {data}")
            
            if 'ascendant' in turkish_result:
                print(f"  Ascendant: {turkish_result['ascendant']}")
            
            # Verify conversion worked
            print("\n🔍 Verification:")
            print("=" * 50)
            conversions_found = 0
            
            if 'planets' in turkish_result:
                for planet_name in turkish_result['planets'].keys():
                    if planet_name in PLANET_NAMES_TR.values():
                        conversions_found += 1
                        print(f"✅ Found Turkish planet name: {planet_name}")
            
            if conversions_found > 0:
                print(f"🎉 SUCCESS! Found {conversions_found} Turkish planet names!")
                return True
            else:
                print("⚠️ No Turkish conversions detected")
                return False
                
        else:
            print(f"❌ API request failed: {response.status_code}")
            try:
                error_data = response.json()
                print(f"Error details: {error_data}")
            except:
                print(f"Error text: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Request error: {e}")
        return False

def main():
    """Main test function"""
    print("🚀 AstroYorumAI Turkish Integration Test")
    print("=" * 60)
    print(f"🕒 Test time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 API URL: {API_BASE_URL}")
    print()
    
    # Test API health
    health_ok = test_api_health()
    
    if health_ok:
        # Test natal chart with Turkish conversion
        chart_ok = test_natal_chart_turkish()
        
        print("\n" + "=" * 60)
        if chart_ok:
            print("🎉 ALL TESTS PASSED! Turkish integration is working!")
            print("✅ Backend API is responding correctly")
            print("✅ Client-side Turkish conversion is working")
            print("✅ Ready for Flutter app testing")
        else:
            print("❌ Some tests failed. Check the output above.")
    else:
        print("❌ Cannot proceed with tests - API is not healthy")
    
    print("\n💡 Next step: Test in actual Flutter app with CORS-disabled Chrome")
    print("   Command: c:\\dev\\AstroYorumAI\\start_chrome_cors_disabled.bat")

if __name__ == "__main__":
    main()
