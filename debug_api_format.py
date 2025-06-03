#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import json

def test_api_response_format():
    """Test the exact API response format"""
    
    test_data = {
        "date": "1990-06-15",
        "time": "14:30", 
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    print("🧪 Testing Production API Response Format...")
    print("-" * 50)
    
    try:
        response = requests.post('https://astroyorumai-api.onrender.com/natal', 
                               json=test_data, timeout=30)
        
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            print("\n📊 Full API Response:")
            print(json.dumps(data, indent=2))
            
            print("\n🌟 Planets Structure:")
            planets = data.get('planets', {})
            for planet_name, planet_data in planets.items():
                print(f"  '{planet_name}': {planet_data}")
            
            print(f"\n🔮 Ascendant: '{data.get('ascendant', 'N/A')}'")
            
            # Check what planet names we're getting
            planet_names = list(planets.keys())
            print(f"\n🔍 Planet Names: {planet_names}")
            
            # Test our mapping
            planet_map = {
                'Sun': 'Güneş',
                'Moon': 'Ay', 
                'Mercury': 'Merkür',
                'Venus': 'Venüs',
                'Mars': 'Mars',
                'Jupiter': 'Jüpiter',
                'Saturn': 'Satürn'
            }
            
            print("\n🇹🇷 Turkish Mapping Test:")
            for eng_name in planet_names:
                tr_name = planet_map.get(eng_name, eng_name)
                print(f"  {eng_name} → {tr_name}")
                
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_api_response_format()
