import requests
import json

print("Testing AstroYorumAI API...")

try:
    # Test root endpoint
    r = requests.get('https://astroyorumai-api.onrender.com/', timeout=10)
    print(f"API Status: {r.status_code}")
    
    if r.status_code == 200:
        data = r.json()
        print(f"Version: {data.get('version', 'unknown')}")
        print(f"Status: {data.get('status', 'unknown')}")
        
        # Test natal endpoint
        natal_data = {
            'date': '1990-05-15',
            'time': '14:30',
            'latitude': 41.0082,
            'longitude': 28.9784
        }
        
        natal_r = requests.post('https://astroyorumai-api.onrender.com/natal', json=natal_data, timeout=30)
        print(f"Natal Status: {natal_r.status_code}")
        
        if natal_r.status_code == 200:
            natal_response = natal_r.json()
            print(f"Has planets: {'planets' in natal_response}")
            if 'planets' in natal_response:
                print(f"Planets: {list(natal_response['planets'].keys())}")
                print("✅ Enhanced backend detected!")
            else:
                print("❌ Simple backend detected")
                
        else:
            print(f"Natal error: {natal_r.text}")
    else:
        print(f"API error: {r.text}")
        
except Exception as e:
    print(f"Error: {e}")
