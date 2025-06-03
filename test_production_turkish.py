#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import json
import time

def test_production_turkish_api():
    """Test production API with Turkish names after deployment"""
    
    # Test data - İstanbul doğumlu biri
    test_data = {
        "date": "1990-06-15",
        "time": "14:30", 
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    print("🧪 Production API Türkçe Test...")
    print(f"Test verisi: {test_data}")
    print("-" * 50)
    
    try:
        # Production API test
        print("📍 Production API test (Render)")
        response = requests.post('https://astroyorumai-api.onrender.com/natal', 
                               json=test_data, 
                               timeout=30)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Başarılı!")
            print(f"Version: {data.get('version', 'N/A')}")
            print(f"Language: {data.get('language', 'N/A')}")
            print(f"Mesaj: {data.get('message', 'N/A')}")
            print(f"Calculation Method: {data.get('calculation_method', 'N/A')}")
            print("\n🌟 Gezegenler:")
            
            planets = data.get('planets', {})
            for planet, info in planets.items():
                if isinstance(info, dict):
                    sign = info.get('sign', 'N/A')
                    deg = info.get('deg', 'N/A')
                    print(f"  {planet}: {sign} ({deg}°)")
                else:
                    print(f"  {planet}: {info}")
            
            ascendant = data.get('ascendant', 'N/A')
            asc_deg = data.get('ascendant_deg', 'N/A')
            print(f"\n🔮 Yükselen: {ascendant} ({asc_deg}°)")
            
            # Check if Turkish names are present
            turkish_planets = ['Güneş', 'Ay', 'Merkür', 'Venüs', 'Mars', 'Jüpiter', 'Satürn']
            found_turkish = any(planet in planets for planet in turkish_planets)
            
            if found_turkish:
                print("\n✅ Türkçe gezegen isimleri tespit edildi!")
            else:
                print("\n⚠️  Henüz İngilizce isimler kullanılıyor - API güncellenmesi bekleniyor")
                
        else:
            print(f"❌ Hata: {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection Error: {e}")
    except Exception as e:
        print(f"❌ Error: {e}")

def check_api_version():
    """Check current API version"""
    try:
        response = requests.get('https://astroyorumai-api.onrender.com/', timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"Current API Version: {data.get('version', 'N/A')}")
            print(f"Build Time: {data.get('build_timestamp', 'N/A')}")
            return data.get('version', '')
        else:
            print(f"API Check failed: {response.status_code}")
            return None
    except Exception as e:
        print(f"API version check error: {e}")
        return None

if __name__ == "__main__":
    print("🔍 API Version Check...")
    current_version = check_api_version()
    print("\n" + "="*60 + "\n")
    
    if current_version and 'turkish' in current_version.lower():
        print("✅ Turkish version detected, testing...")
    else:
        print("⏳ Waiting for deployment... Testing anyway...")
    
    test_production_turkish_api()
