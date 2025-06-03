#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import json

def test_turkish_api():
    """Test Turkish planet names and signs"""
    
    # Test data - İstanbul doğumlu biri
    test_data = {
        "date": "1990-06-15",
        "time": "14:30", 
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    print("🧪 Türkçe API Test Başlıyor...")
    print(f"Test verisi: {test_data}")
    print("-" * 50)
    
    try:
        # Local API test
        print("📍 Local API test (localhost:5000)")
        response = requests.post('http://localhost:5000/natal', 
                               json=test_data, 
                               timeout=10)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Başarılı!")
            print(f"Version: {data.get('version', 'N/A')}")
            print(f"Language: {data.get('language', 'N/A')}")
            print(f"Mesaj: {data.get('message', 'N/A')}")
            print("\n🌟 Gezegenler (Türkçe):")
            
            planets = data.get('planets', {})
            for planet, info in planets.items():
                print(f"  {planet}: {info['sign']} ({info['deg']}°)")
            
            ascendant = data.get('ascendant', 'N/A')
            asc_deg = data.get('ascendant_deg', 'N/A')
            print(f"\n🔮 Yükselen: {ascendant} ({asc_deg}°)")
            
        else:
            print(f"❌ Hata: {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection Error: {e}")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_turkish_api()
