#!/usr/bin/env python3
"""
Test the natal chart endpoint with real astrological data
"""
import requests
import json

BASE_URL = "https://astroyorumai-api.onrender.com"

def test_natal_chart():
    """Test natal chart calculation with real birth data"""
    print("🔮 Testing natal chart calculation with real astrology...")
    
    # Test data - A specific birth date/time/location
    natal_data = {
        "date": "1990-05-15",
        "time": "14:30",
        "latitude": 41.0082,  # Istanbul
        "longitude": 28.9784
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/natal",
            json=natal_data,
            timeout=30
        )
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ SUCCESS!")
            print(f"📊 Response structure: {list(data.keys())}")
            
            if 'planets' in data:
                print("\n🪐 Planets:")
                for planet, info in data['planets'].items():
                    print(f"   {planet}: {info}")
            
            if 'ascendant' in data:
                print(f"\n🔸 Ascendant: {data['ascendant']}")
                if 'ascendant_deg' in data:
                    print(f"   Degree: {data['ascendant_deg']}")
            
            if 'message' in data:
                print(f"\n💬 Message: {data['message']}")
                
            # Check if we got real calculations or mock data
            if 'flatlib' in data.get('message', '').lower() or 'real' in data.get('message', '').lower():
                print("\n🎉 USING REAL ASTROLOGICAL CALCULATIONS!")
            elif 'mock' in data.get('message', '').lower() or 'enhanced mock' in data.get('message', '').lower():
                print("\n📝 Using mock data (flatlib not available)")
            
            return True
        else:
            print(f"❌ Failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("🚀 AstroYorumAI Natal Chart Test")
    print("="*40)
    test_natal_chart()
