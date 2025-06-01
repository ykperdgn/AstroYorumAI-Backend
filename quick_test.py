import requests
import json

# Test natal chart endpoint
data = {
    'date': '1990-05-15',
    'time': '14:30',
    'latitude': 41.0082,
    'longitude': 28.9784
}

try:
    r = requests.post('https://astroyorumai-api.onrender.com/natal', json=data, timeout=30)
    print(f'Status: {r.status_code}')
    
    if r.status_code == 200:
        response = r.json()
        print(f'Response keys: {list(response.keys())}')
        print(f'Has planets: {"planets" in response}')
        
        if 'planets' in response:
            print("✅ Enhanced backend detected!")
            print(f'Available planets: {list(response["planets"].keys())}')
        else:
            print("❌ Simple backend detected")
            print(f'Response: {response}')
    else:
        print(f'Error: {r.text}')
        
except Exception as e:
    print(f'Error: {e}')
